// SPDX-License-Identifier: BSD-3-Clause
//
// See box2d_shim.h for the rationale behind this file.

#include "box2d_shim.h"

// The Haskell bindings pass ids by value as Word32/Word64; that pun is only
// sound while the ids stay register-sized integer structs.
_Static_assert(sizeof(b2WorldId) == 4, "b2WorldId is passed as Word32");
_Static_assert(sizeof(b2BodyId) == 8, "b2BodyId is passed as Word64");
_Static_assert(sizeof(b2ShapeId) == 8, "b2ShapeId is passed as Word64");
_Static_assert(sizeof(b2ChainId) == 8, "b2ChainId is passed as Word64");
_Static_assert(sizeof(b2JointId) == 8, "b2JointId is passed as Word64");

// base.h -----------------------------------------------------------------

void hs_b2GetVersion(b2Version* out)
{
	*out = b2GetVersion();
}

// math_functions.h -------------------------------------------------------

bool hs_b2IsValidVec2(const b2Vec2* a)
{
	return b2IsValidVec2(*a);
}

bool hs_b2IsValidRotation(const b2Rot* q)
{
	return b2IsValidRotation(*q);
}

bool hs_b2IsValidTransform(const b2Transform* t)
{
	return b2IsValidTransform(*t);
}

bool hs_b2IsValidAABB(const b2AABB* a)
{
	return b2IsValidAABB(*a);
}

bool hs_b2IsValidPlane(const b2Plane* a)
{
	return b2IsValidPlane(*a);
}

void hs_b2ComputeCosSin(float radians, b2CosSin* out)
{
	*out = b2ComputeCosSin(radians);
}

void hs_b2MakeRot(float radians, b2Rot* out)
{
	*out = b2MakeRot(radians);
}

// types.h: default definition constructors --------------------------------

void hs_b2DefaultWorldDef(b2WorldDef* out)
{
	*out = b2DefaultWorldDef();
}

void hs_b2DefaultBodyDef(b2BodyDef* out)
{
	*out = b2DefaultBodyDef();
}

void hs_b2DefaultShapeDef(b2ShapeDef* out)
{
	*out = b2DefaultShapeDef();
}

void hs_b2DefaultFilter(b2Filter* out)
{
	*out = b2DefaultFilter();
}

void hs_b2DefaultSurfaceMaterial(b2SurfaceMaterial* out)
{
	*out = b2DefaultSurfaceMaterial();
}

void hs_b2DefaultQueryFilter(b2QueryFilter* out)
{
	*out = b2DefaultQueryFilter();
}

void hs_b2DefaultChainDef(b2ChainDef* out)
{
	*out = b2DefaultChainDef();
}

void hs_b2DefaultExplosionDef(b2ExplosionDef* out)
{
	*out = b2DefaultExplosionDef();
}

// types.h: joint definition defaults ---------------------------------------

void hs_b2DefaultDistanceJointDef(b2DistanceJointDef* out)
{
	*out = b2DefaultDistanceJointDef();
}

void hs_b2DefaultMotorJointDef(b2MotorJointDef* out)
{
	*out = b2DefaultMotorJointDef();
}

void hs_b2DefaultPrismaticJointDef(b2PrismaticJointDef* out)
{
	*out = b2DefaultPrismaticJointDef();
}

void hs_b2DefaultRevoluteJointDef(b2RevoluteJointDef* out)
{
	*out = b2DefaultRevoluteJointDef();
}

void hs_b2DefaultWeldJointDef(b2WeldJointDef* out)
{
	*out = b2DefaultWeldJointDef();
}

void hs_b2DefaultWheelJointDef(b2WheelJointDef* out)
{
	*out = b2DefaultWheelJointDef();
}

void hs_b2DefaultFilterJointDef(b2FilterJointDef* out)
{
	*out = b2DefaultFilterJointDef();
}


// Callback trampolines ------------------------------------------------------
// GHC callbacks cannot receive structs by value, so these fixed C functions
// take the by-value b2Pos/b2Vec2 arguments and forward pointers to a
// Haskell-wrapped function carried in the context slot.

typedef float (*hs_b2CastResultHsFcn)(b2ShapeId shapeId, const b2Pos* point, const b2Vec2* normal, float fraction,
									  void* context);

typedef bool (*hs_b2PreSolveHsFcn)(b2ShapeId shapeIdA, b2ShapeId shapeIdB, const b2Pos* point, const b2Vec2* normal,
								   void* context);

float hs_b2CastResultTrampoline(b2ShapeId shapeId, b2Pos point, b2Vec2 normal, float fraction, void* context)
{
	hs_b2Closure* c = context;
	return ((hs_b2CastResultHsFcn)c->fn)(shapeId, &point, &normal, fraction, c->context);
}

bool hs_b2PreSolveTrampoline(b2ShapeId shapeIdA, b2ShapeId shapeIdB, b2Pos point, b2Vec2 normal, void* context)
{
	hs_b2Closure* c = context;
	return ((hs_b2PreSolveHsFcn)c->fn)(shapeIdA, shapeIdB, &point, &normal, c->context);
}

// chains ---------------------------------------------------------------------

// The toggles need each segment's b2ShapeId, but b2Chain_GetSegments always
// copies from segment zero, so fetching them through the public API would
// force a heap allocation (with a silent no-op as its only failure mode).
// These internal headers give the loop direct access to the chain's shape
// indices instead; b2GetChainShape is static in shape.c, so its two-line
// lookup is inlined here.
#include "physics_world.h"
#include "shape.h"

typedef void (*hs_b2SegmentToggle)(b2ShapeId shapeId, bool flag);

static void hs_b2Chain_ForEachSegment(b2ChainId chainId, hs_b2SegmentToggle toggle, bool flag)
{
	b2World* world = b2GetWorldLocked(chainId.world0);
	if (world == NULL)
	{
		return;
	}

	int id = chainId.index1 - 1;
	b2ChainShape* chain = b2Array_Get(world->chainShapes, id);
	B2_ASSERT(chain->id == id && chain->generation == chainId.generation);

	for (int i = 0; i < chain->count; ++i)
	{
		int shapeId = chain->shapeIndices[i];
		b2Shape* shape = b2Array_Get(world->shapes, shapeId);
		toggle((b2ShapeId){ shapeId + 1, chainId.world0, shape->generation }, flag);
	}
}

void hs_b2Chain_EnableContactEvents(b2ChainId chainId, bool flag)
{
	hs_b2Chain_ForEachSegment(chainId, b2Shape_EnableContactEvents, flag);
}

void hs_b2Chain_EnableHitEvents(b2ChainId chainId, bool flag)
{
	hs_b2Chain_ForEachSegment(chainId, b2Shape_EnableHitEvents, flag);
}
