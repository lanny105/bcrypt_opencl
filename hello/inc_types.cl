/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

typedef uchar  u8;
typedef ushort u16;
typedef uint   u32;
typedef ulong  u64;

typedef u8  u8a  __attribute__ ((aligned (8)));
typedef u16 u16a __attribute__ ((aligned (8)));
typedef u32 u32a __attribute__ ((aligned (8)));
typedef u64 u64a __attribute__ ((aligned (8)));

#ifndef NEW_SIMD_CODE
#undef  VECT_SIZE
#define VECT_SIZE 1
#endif

#define CONCAT(a, b)       a##b
#define VTYPE(type, width) CONCAT(type, width)

#if VECT_SIZE == 1
typedef uchar   u8x;
typedef ushort  u16x;
typedef uint    u32x;
typedef ulong   u64x;
#else
typedef VTYPE(uchar,  VECT_SIZE)  u8x;
typedef VTYPE(ushort, VECT_SIZE) u16x;
typedef VTYPE(uint,   VECT_SIZE) u32x;
typedef VTYPE(ulong,  VECT_SIZE) u64x;
#endif

u32 l32_from_64_S (u64 a)
{
    const u32 r = (u32) (a);
    
    return r;
}

u32 h32_from_64_S (u64 a)
{
    a >>= 32;
    
    const u32 r = (u32) (a);
    
    return r;
}

u64 hl32_to_64_S (const u32 a, const u32 b)
{
    return as_ulong ((uint2) (b, a));
}

u32x l32_from_64 (u64x a)
{
    u32x r;
    
#if VECT_SIZE == 1
    r    = (u32) a;
#endif
    
#if VECT_SIZE >= 2
    r.s0 = (u32) a.s0;
    r.s1 = (u32) a.s1;
#endif
    
#if VECT_SIZE >= 4
    r.s2 = (u32) a.s2;
    r.s3 = (u32) a.s3;
#endif
    
#if VECT_SIZE >= 8
    r.s4 = (u32) a.s4;
    r.s5 = (u32) a.s5;
    r.s6 = (u32) a.s6;
    r.s7 = (u32) a.s7;
#endif
    
#if VECT_SIZE >= 16
    r.s8 = (u32) a.s8;
    r.s9 = (u32) a.s9;
    r.sa = (u32) a.sa;
    r.sb = (u32) a.sb;
    r.sc = (u32) a.sc;
    r.sd = (u32) a.sd;
    r.se = (u32) a.se;
    r.sf = (u32) a.sf;
#endif
    
    return r;
}

u32x h32_from_64 (u64x a)
{
    a >>= 32;
    
    u32x r;
    
#if VECT_SIZE == 1
    r    = (u32) a;
#endif
    
#if VECT_SIZE >= 2
    r.s0 = (u32) a.s0;
    r.s1 = (u32) a.s1;
#endif
    
#if VECT_SIZE >= 4
    r.s2 = (u32) a.s2;
    r.s3 = (u32) a.s3;
#endif
    
#if VECT_SIZE >= 8
    r.s4 = (u32) a.s4;
    r.s5 = (u32) a.s5;
    r.s6 = (u32) a.s6;
    r.s7 = (u32) a.s7;
#endif
    
#if VECT_SIZE >= 16
    r.s8 = (u32) a.s8;
    r.s9 = (u32) a.s9;
    r.sa = (u32) a.sa;
    r.sb = (u32) a.sb;
    r.sc = (u32) a.sc;
    r.sd = (u32) a.sd;
    r.se = (u32) a.se;
    r.sf = (u32) a.sf;
#endif
    
    return r;
}

u64x hl32_to_64 (const u32x a, const u32x b)
{
    u64x r;
    
#if VECT_SIZE == 1
    r    = as_ulong ((uint2) (b,    a));
#endif
    
#if VECT_SIZE >= 2
    r.s0 = as_ulong ((uint2) (b.s0, a.s0));
    r.s1 = as_ulong ((uint2) (b.s1, a.s1));
#endif
    
#if VECT_SIZE >= 4
    r.s2 = as_ulong ((uint2) (b.s2, a.s2));
    r.s3 = as_ulong ((uint2) (b.s3, a.s3));
#endif
    
#if VECT_SIZE >= 8
    r.s4 = as_ulong ((uint2) (b.s4, a.s4));
    r.s5 = as_ulong ((uint2) (b.s5, a.s5));
    r.s6 = as_ulong ((uint2) (b.s6, a.s6));
    r.s7 = as_ulong ((uint2) (b.s7, a.s7));
#endif
    
#if VECT_SIZE >= 16
    r.s8 = as_ulong ((uint2) (b.s8, a.s8));
    r.s9 = as_ulong ((uint2) (b.s9, a.s9));
    r.sa = as_ulong ((uint2) (b.sa, a.sa));
    r.sb = as_ulong ((uint2) (b.sb, a.sb));
    r.sc = as_ulong ((uint2) (b.sc, a.sc));
    r.sd = as_ulong ((uint2) (b.sd, a.sd));
    r.se = as_ulong ((uint2) (b.se, a.se));
    r.sf = as_ulong ((uint2) (b.sf, a.sf));
#endif
    
    return r;
}

#ifdef IS_AMD
u32 swap32_S (const u32 v)
{
    return bitselect (rotate (v, 24u), rotate (v, 8u), 0x00ff00ffu);
}

u64 swap64_S (const u64 v)
{
    return bitselect (bitselect (rotate (v, 24ul),
                                 rotate (v,  8ul), 0x000000ff000000fful),
                      bitselect (rotate (v, 56ul),
                                 rotate (v, 40ul), 0x00ff000000ff0000ul),
                      0xffff0000ffff0000ul);
}

u32 rotr32_S (const u32 a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32 rotl32_S (const u32 a, const u32 n)
{
    return rotate (a, n);
}

u64 rotr64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) (64 - n));
}

u64 rotl64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) n);
}

u32x swap32 (const u32x v)
{
    return bitselect (rotate (v, 24u), rotate (v, 8u), 0x00ff00ffu);
}

u64x swap64 (const u64x v)
{
    return bitselect (bitselect (rotate (v, 24ul),
                                 rotate (v,  8ul), 0x000000ff000000fful),
                      bitselect (rotate (v, 56ul),
                                 rotate (v, 40ul), 0x00ff000000ff0000ul),
                      0xffff0000ffff0000ul);
}

u32x rotr32 (const u32x a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32x rotl32 (const u32x a, const u32 n)
{
    return rotate (a, n);
}

u64x rotr64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) (64 - n));
}

u64x rotl64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) n);
}

u32x __bfe (const u32x a, const u32x b, const u32x c)
{
    return amd_bfe (a, b, c);
}

u32 __bfe_S (const u32 a, const u32 b, const u32 c)
{
    return amd_bfe (a, b, c);
}

u32 amd_bytealign_S (const u32 a, const u32 b, const u32 c)
{
    return amd_bytealign (a, b, c);
}
#endif

#ifdef IS_NV
u32 swap32_S (const u32 v)
{
    return (as_uint (as_uchar4 (v).s3210));
}

u64 swap64_S (const u64 v)
{
    return (as_ulong (as_uchar8 (v).s76543210));
}

u32 rotr32_S (const u32 a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32 rotl32_S (const u32 a, const u32 n)
{
    return rotate (a, n);
}

u64 rotr64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) (64 - n));
}

u64 rotl64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) n);
}

u32x swap32 (const u32x v)
{
    return ((v >> 24) & 0x000000ff)
    | ((v >>  8) & 0x0000ff00)
    | ((v <<  8) & 0x00ff0000)
    | ((v << 24) & 0xff000000);
}

u64x swap64 (const u64x v)
{
    return ((v >> 56) & 0x00000000000000ff)
    | ((v >> 40) & 0x000000000000ff00)
    | ((v >> 24) & 0x0000000000ff0000)
    | ((v >>  8) & 0x00000000ff000000)
    | ((v <<  8) & 0x000000ff00000000)
    | ((v << 24) & 0x0000ff0000000000)
    | ((v << 40) & 0x00ff000000000000)
    | ((v << 56) & 0xff00000000000000);
}

u32x rotr32 (const u32x a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32x rotl32 (const u32x a, const u32 n)
{
    return rotate (a, n);
}

u64x rotr64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) (64 - n));
}

u64x rotl64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) n);
}

u32x __byte_perm (const u32x a, const u32x b, const u32x c)
{
    u32x r;
    
#if VECT_SIZE == 1
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r)    : "r"(a),    "r"(b),    "r"(c)   );
#endif
    
#if VECT_SIZE >= 2
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s0) : "r"(a.s0), "r"(b.s0), "r"(c.s0));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s1) : "r"(a.s1), "r"(b.s1), "r"(c.s1));
#endif
    
#if VECT_SIZE >= 4
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s2) : "r"(a.s2), "r"(b.s2), "r"(c.s2));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s3) : "r"(a.s3), "r"(b.s3), "r"(c.s3));
#endif
    
#if VECT_SIZE >= 8
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s4) : "r"(a.s4), "r"(b.s4), "r"(c.s4));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s5) : "r"(a.s5), "r"(b.s5), "r"(c.s5));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s6) : "r"(a.s6), "r"(b.s6), "r"(c.s6));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s7) : "r"(a.s7), "r"(b.s7), "r"(c.s7));
#endif
    
#if VECT_SIZE >= 16
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s8) : "r"(a.s8), "r"(b.s8), "r"(c.s8));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.s9) : "r"(a.s9), "r"(b.s9), "r"(c.s9));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.sa) : "r"(a.sa), "r"(b.sa), "r"(c.sa));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.sb) : "r"(a.sb), "r"(b.sb), "r"(c.sb));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.sc) : "r"(a.sc), "r"(b.sc), "r"(c.sc));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.sd) : "r"(a.sd), "r"(b.sd), "r"(c.sd));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.se) : "r"(a.se), "r"(b.se), "r"(c.se));
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r.sf) : "r"(a.sf), "r"(b.sf), "r"(c.sf));
#endif
    
    return r;
}

u32 __byte_perm_S (const u32 a, const u32 b, const u32 c)
{
    u32 r;
    
    asm ("prmt.b32 %0, %1, %2, %3;" : "=r"(r) : "r"(a), "r"(b), "r"(c));
    
    return r;
}

u32x __bfe (const u32x a, const u32x b, const u32x c)
{
    u32x r;
    
#if VECT_SIZE == 1
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r)    : "r"(a),    "r"(b),    "r"(c));
#endif
    
#if VECT_SIZE >= 2
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s0) : "r"(a.s0), "r"(b.s0), "r"(c.s0));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s1) : "r"(a.s1), "r"(b.s1), "r"(c.s1));
#endif
    
#if VECT_SIZE >= 4
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s2) : "r"(a.s2), "r"(b.s2), "r"(c.s2));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s3) : "r"(a.s3), "r"(b.s3), "r"(c.s3));
#endif
    
#if VECT_SIZE >= 8
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s4) : "r"(a.s4), "r"(b.s4), "r"(c.s4));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s5) : "r"(a.s5), "r"(b.s5), "r"(c.s5));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s6) : "r"(a.s6), "r"(b.s6), "r"(c.s6));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s7) : "r"(a.s7), "r"(b.s7), "r"(c.s7));
#endif
    
#if VECT_SIZE >= 16
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s8) : "r"(a.s8), "r"(b.s8), "r"(c.s8));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.s9) : "r"(a.s9), "r"(b.s9), "r"(c.s9));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.sa) : "r"(a.sa), "r"(b.sa), "r"(c.sa));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.sb) : "r"(a.sb), "r"(b.sb), "r"(c.sb));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.sc) : "r"(a.sc), "r"(b.sc), "r"(c.sc));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.sd) : "r"(a.sd), "r"(b.sd), "r"(c.sd));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.se) : "r"(a.se), "r"(b.se), "r"(c.se));
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r.sf) : "r"(a.sf), "r"(b.sf), "r"(c.sf));
#endif
    
    return r;
}

u32 __bfe_S (const u32 a, const u32 b, const u32 c)
{
    u32 r;
    
    asm ("bfe.u32 %0, %1, %2, %3;" : "=r"(r) : "r"(a), "r"(b), "r"(c));
    
    return r;
}

u32x amd_bytealign (const u32x a, const u32x b, const u32x c)
{
    u32x r;
    
#if CUDA_ARCH >= 350
    
#if VECT_SIZE == 1
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r)    : "r"(b),    "r"(a),    "r"((c & 3) * 8));
#endif
    
#if VECT_SIZE >= 2
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s0) : "r"(b.s0), "r"(a.s0), "r"((c.s0 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s1) : "r"(b.s1), "r"(a.s1), "r"((c.s1 & 3) * 8));
#endif
    
#if VECT_SIZE >= 4
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s2) : "r"(b.s2), "r"(a.s2), "r"((c.s2 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s3) : "r"(b.s3), "r"(a.s3), "r"((c.s3 & 3) * 8));
#endif
    
#if VECT_SIZE >= 8
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s4) : "r"(b.s4), "r"(a.s4), "r"((c.s4 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s5) : "r"(b.s5), "r"(a.s5), "r"((c.s5 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s6) : "r"(b.s6), "r"(a.s6), "r"((c.s6 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s7) : "r"(b.s7), "r"(a.s7), "r"((c.s7 & 3) * 8));
#endif
    
#if VECT_SIZE >= 16
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s8) : "r"(b.s8), "r"(a.s8), "r"((c.s8 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.s9) : "r"(b.s9), "r"(a.s9), "r"((c.s9 & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.sa) : "r"(b.sa), "r"(a.sa), "r"((c.sa & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.sb) : "r"(b.sb), "r"(a.sb), "r"((c.sb & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.sc) : "r"(b.sc), "r"(a.sc), "r"((c.sc & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.sd) : "r"(b.sd), "r"(a.sd), "r"((c.sd & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.se) : "r"(b.se), "r"(a.se), "r"((c.se & 3) * 8));
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r.sf) : "r"(b.sf), "r"(a.sf), "r"((c.sf & 3) * 8));
#endif
    
#else
    
    r = __byte_perm (b, a, ((u32x) (0x76543210) >> ((c & 3) * 4)) & 0xffff);
    
#endif
    
    return r;
}

u32 amd_bytealign_S (const u32 a, const u32 b, const u32 c)
{
    u32 r;
    
#if CUDA_ARCH >= 350
    
    asm ("shf.r.wrap.b32 %0, %1, %2, %3;" : "=r"(r) : "r"(b), "r"(a), "r"((c & 3) * 8));
    
#else
    
    r = __byte_perm_S (b, a, (0x76543210 >> ((c & 3) * 4)) & 0xffff);
    
#endif
    
    return r;
}
#endif

#ifdef IS_GENERIC
u32 swap32_S (const u32 v)
{
    return (as_uint (as_uchar4 (v).s3210));
}

u64 swap64_S (const u64 v)
{
    return (as_ulong (as_uchar8 (v).s76543210));
}

u32 rotr32_S (const u32 a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32 rotl32_S (const u32 a, const u32 n)
{
    return rotate (a, n);
}

u64 rotr64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) (64 - n));
}

u64 rotl64_S (const u64 a, const u32 n)
{
    return rotate (a, (u64) n);
}

u32x swap32 (const u32x v)
{
    return ((v >> 24) & 0x000000ff)
    | ((v >>  8) & 0x0000ff00)
    | ((v <<  8) & 0x00ff0000)
    | ((v << 24) & 0xff000000);
}

u64x swap64 (const u64x v)
{
    return ((v >> 56) & 0x00000000000000ff)
    | ((v >> 40) & 0x000000000000ff00)
    | ((v >> 24) & 0x0000000000ff0000)
    | ((v >>  8) & 0x00000000ff000000)
    | ((v <<  8) & 0x000000ff00000000)
    | ((v << 24) & 0x0000ff0000000000)
    | ((v << 40) & 0x00ff000000000000)
    | ((v << 56) & 0xff00000000000000);
}

u32x rotr32 (const u32x a, const u32 n)
{
    return rotate (a, (32 - n));
}

u32x rotl32 (const u32x a, const u32 n)
{
    return rotate (a, n);
}

u64x rotr64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) (64 - n));
}

u64x rotl64 (const u64x a, const u32 n)
{
    return rotate (a, (u64x) n);
}

u32x __bfe (const u32x a, const u32x b, const u32x c)
{
#define BIT(x)      ((u32x) (1u) << (x))
#define BIT_MASK(x) (BIT (x) - 1)
#define BFE(x,y,z)  (((x) >> (y)) & BIT_MASK (z))
    
    return BFE (a, b, c);
    
#undef BIT
#undef BIT_MASK
#undef BFE
}

u32 __bfe_S (const u32 a, const u32 b, const u32 c)
{
#define BIT(x)      (1u << (x))
#define BIT_MASK(x) (BIT (x) - 1)
#define BFE(x,y,z)  (((x) >> (y)) & BIT_MASK (z))
    
    return BFE (a, b, c);
    
#undef BIT
#undef BIT_MASK
#undef BFE
}

u32x amd_bytealign (const u32x a, const u32x b, const u32 c)
{
#if VECT_SIZE == 1
    const u64x tmp = ((((u64x) (a)) << 32) | ((u64x) (b))) >> ((c & 3) * 8);
    
    return (u32x) (tmp);
#endif
    
#if VECT_SIZE == 2
    const u64x tmp = ((((u64x) (a.s0, a.s1)) << 32) | ((u64x) (b.s0, b.s1))) >> ((c & 3) * 8);
    
    return (u32x) (tmp.s0, tmp.s1);
#endif
    
#if VECT_SIZE == 4
    const u64x tmp = ((((u64x) (a.s0, a.s1, a.s2, a.s3)) << 32) | ((u64x) (b.s0, b.s1, b.s2, b.s3))) >> ((c & 3) * 8);
    
    return (u32x) (tmp.s0, tmp.s1, tmp.s2, tmp.s3);
#endif
    
#if VECT_SIZE == 8
    const u64x tmp = ((((u64x) (a.s0, a.s1, a.s2, a.s3, a.s4, a.s5, a.s6, a.s7)) << 32) | ((u64x) (b.s0, b.s1, b.s2, b.s3, b.s4, b.s5, b.s6, b.s7))) >> ((c & 3) * 8);
    
    return (u32x) (tmp.s0, tmp.s1, tmp.s2, tmp.s3, tmp.s4, tmp.s5, tmp.s6, tmp.s7);
#endif
    
#if VECT_SIZE == 16
    const u64x tmp = ((((u64x) (a.s0, a.s1, a.s2, a.s3, a.s4, a.s5, a.s6, a.s7, a.s8, a.s9, a.sa, a.sb, a.sc, a.sd, a.se, a.sf)) << 32) | ((u64x) (b.s0, b.s1, b.s2, b.s3, b.s4, b.s5, b.s6, b.s7, b.s8, b.s9, b.sa, b.sb, b.sc, b.sd, b.se, b.sf))) >> ((c & 3) * 8);
    
    return (u32x) (tmp.s0, tmp.s1, tmp.s2, tmp.s3, tmp.s4, tmp.s5, tmp.s6, tmp.s7, tmp.s8, tmp.s9, tmp.sa, tmp.sb, tmp.sc, tmp.sd, tmp.se, tmp.sf);
#endif
}

u32 amd_bytealign_S (const u32 a, const u32 b, const u32 c)
{
    const u64 tmp = ((((u64) a) << 32) | ((u64) b)) >> ((c & 3) * 8);
    
    return (u32) (tmp);
}

#endif

typedef struct bcrypt_tmp
    {
        u32 E[18];
        
        u32 P[18];
        
        u32 S0[256];
        u32 S1[256];
        u32 S2[256];
        u32 S3[256];
        
    } bcrypt_tmp_t;


typedef struct pw
    {
        u32 i[64];
        
        u32 pw_len;
        
        u32 alignment_placeholder_1;
        u32 alignment_placeholder_2;
        u32 alignment_placeholder_3;
        
    } pw_t;

