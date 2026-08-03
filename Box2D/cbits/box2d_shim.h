// SPDX-License-Identifier: BSD-3-Clause
//
// Thin C shim for the Box2D Haskell bindings.
//
// The Box2D public API passes and returns several small structs *by value*,
// which GHC's FFI cannot express in general. Ids are exempt: they are
// integer-only structs of at most 8 bytes, and on the supported 64-bit ABIs
// (x86-64 SysV and Win64, AArch64) they travel in a general-purpose register
// exactly like a uint32_t/uint64_t, so the Haskell side imports id-only
// functions directly with word-sized newtypes (see the _Static_asserts in
// box2d_shim.c). Everything else — float structs, which travel in vector
// registers or by hidden reference, and the config defs — is wrapped here
// into a pointer-based form. The naming convention is hs_<original b2 name>;
// a value that was returned by value is written through a trailing
// out-pointer, and a non-id value that was passed by value is taken through
// a const in-pointer.

#pragma once

#include "box2d/box2d.h"

// base.h -----------------------------------------------------------------

// b2Version b2GetVersion(void)
void hs_b2GetVersion(b2Version* out);

// math_functions.h -------------------------------------------------------

bool hs_b2IsValidVec2(const b2Vec2* a);
bool hs_b2IsValidRotation(const b2Rot* q);
bool hs_b2IsValidTransform(const b2Transform* t);
bool hs_b2IsValidAABB(const b2AABB* a);
bool hs_b2IsValidPlane(const b2Plane* a);

// b2CosSin b2ComputeCosSin(float radians)
void hs_b2ComputeCosSin(float radians, b2CosSin* out);

// b2Rot b2MakeRot(float radians)
void hs_b2MakeRot(float radians, b2Rot* out);

// types.h: default definition constructors --------------------------------

void hs_b2DefaultWorldDef(b2WorldDef* out);
void hs_b2DefaultBodyDef(b2BodyDef* out);
void hs_b2DefaultShapeDef(b2ShapeDef* out);
void hs_b2DefaultFilter(b2Filter* out);
void hs_b2DefaultSurfaceMaterial(b2SurfaceMaterial* out);
void hs_b2DefaultQueryFilter(b2QueryFilter* out);
void hs_b2DefaultChainDef(b2ChainDef* out);
void hs_b2DefaultExplosionDef(b2ExplosionDef* out);

// The world / body by-value accessors now live in the generated
// box2d_gen_shim.{h,c} (hsg_ prefix). This file keeps only the shims backing
// the hand-written scaffolding (base.h, math_functions.h, the *Def defaults).

// types.h: joint definition defaults ---------------------------------------

void hs_b2DefaultDistanceJointDef(b2DistanceJointDef* out);
void hs_b2DefaultMotorJointDef(b2MotorJointDef* out);
void hs_b2DefaultPrismaticJointDef(b2PrismaticJointDef* out);
void hs_b2DefaultRevoluteJointDef(b2RevoluteJointDef* out);
void hs_b2DefaultWeldJointDef(b2WeldJointDef* out);
void hs_b2DefaultWheelJointDef(b2WheelJointDef* out);
void hs_b2DefaultFilterJointDef(b2FilterJointDef* out);

// chains ---------------------------------------------------------------------

// b2CreateChain leaves contact/hit events disabled on its segment shapes;
// these toggle every segment of a chain in one call instead of one FFI
// round-trip per segment.
void hs_b2Chain_EnableContactEvents(b2ChainId chainId, bool flag);
void hs_b2Chain_EnableHitEvents(b2ChainId chainId, bool flag);

// Callback trampolines: fixed C functions with the engine's callback
// signatures. The context must point at an hs_b2Closure whose fn is a
// Haskell-wrapped function of the pointer-argument variant of the signature
// and whose context is the user context it receives.

typedef struct hs_b2Closure
{
	void* fn;
	void* context;
} hs_b2Closure;

float hs_b2CastResultTrampoline(b2ShapeId shapeId, b2Pos point, b2Vec2 normal, float fraction, void* context);
bool hs_b2PreSolveTrampoline(b2ShapeId shapeIdA, b2ShapeId shapeIdB, b2Pos point, b2Vec2 normal, void* context);
