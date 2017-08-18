#include <stdio.h>
#include <stdlib.h>

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

#define MEM_SIZE (128)
#define MAX_SOURCE_SIZE (0x100000)

#include "bcrypt.h"

typedef uint8_t  u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef struct pw
{
    u32 i[64];
    
    u32 pw_len;
    
    u32 alignment_placeholder_1;
    u32 alignment_placeholder_2;
    u32 alignment_placeholder_3;
    
} pw_t;


int main()
{
    cl_device_id device_id = NULL;
    cl_context context = NULL;
    cl_command_queue command_queue = NULL;
    cl_mem bufferA = NULL;
    cl_mem bufferB = NULL;
    cl_mem bufferC = NULL;
    cl_mem bufferD = NULL;
    cl_program program = NULL;
    cl_kernel kernel = NULL;
    cl_platform_id platform_id = NULL;
    cl_uint ret_num_devices;
    cl_uint ret_num_platforms;
    cl_int ret;
    
    u32 workFactor = 5, loop_cnt = 1 << workFactor, *loop_cnt_ptr = &loop_cnt;
    pw_t pw, *pws = &pw;
    char salt[MEM_SIZE] = "$2a$05$EIPAmlpctDvZLPDTt8iY1u";
    
//    bcrypt_gensalt(workFactor, salt);
    
    char hash[BCRYPT_HASHSIZE];
    char pwd[MEM_SIZE] = "oa";
    
    u32 salt_u32[4], result[6];
    
    BF_decode(salt_u32, &salt[7], 16);
    BF_swap(salt_u32, 4);
    char *ptr = pwd;
    for (int i = 0; i < 18; i++) {
        u32 tmp = 0;
        for (int j = 0; j < 4; j++) {
            tmp <<= 8;
            tmp |= (unsigned char)*ptr;
            if (!*ptr) {
                tmp <<= 8 * (3-j);
                break;
            }
            else ptr++;
        }
        
        pw.i[i] = tmp;
        BF_swap(&pw.i[i], 1);
    }
    pw.pw_len = strlen(pwd);
    
    FILE *fp;
    char fileName[] = "./hello.cl";
    char *source_str;
    size_t source_size;
    
    /* Load the source code containing the kernel*/
    fp = fopen(fileName, "r");
    if (!fp) {
        fprintf(stderr, "Failed to load kernel.\n");
        exit(1);
    }
    source_str = (char*)malloc(MAX_SOURCE_SIZE);
    source_size = fread(source_str, 1, MAX_SOURCE_SIZE, fp);
    fclose(fp);
    
    /* Get Platform and Device Info */
    ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
    ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_DEFAULT, 1, &device_id, &ret_num_devices);
    
    /* Create OpenCL context */
    context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);
    
    /* Create Command Queue */
    command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
    
    /* Create Memory Buffer */
    bufferA = clCreateBuffer(context, CL_MEM_READ_WRITE, 1 * sizeof(pw_t), NULL, &ret);
    bufferB = clCreateBuffer(context, CL_MEM_READ_WRITE, 4 * sizeof(u32), NULL, &ret);
    bufferC = clCreateBuffer(context, CL_MEM_READ_WRITE, 1 * sizeof(u32), NULL, &ret);
    bufferD = clCreateBuffer(context, CL_MEM_READ_WRITE, 6 * sizeof(u32), NULL, &ret);

    ret = clEnqueueWriteBuffer(command_queue, bufferA, CL_FALSE, 0, sizeof(pw_t) * 1, pws, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, bufferB, CL_FALSE, 0, sizeof(u32) * 4, salt_u32, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, bufferC, CL_FALSE, 0, sizeof(u32) * 1, loop_cnt_ptr, 0, NULL, NULL);
    ret = clEnqueueWriteBuffer(command_queue, bufferD, CL_FALSE, 0, sizeof(u32) * 6, result, 0, NULL, NULL);
    
    /* Create Kernel Program from the source */
    program = clCreateProgramWithSource(context, 1, (const char **)&source_str,
                                        (const size_t *)&source_size, &ret);
    
    /* Build Kernel Program */
    ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);
    
    /* Create OpenCL Kernel */
    kernel = clCreateKernel(program, "bcrypt", &ret);
    
    /* Set OpenCL Kernel Parameters */
    ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&bufferA);
    ret = clSetKernelArg(kernel, 1, sizeof(cl_mem), (void *)&bufferB);
    ret = clSetKernelArg(kernel, 2, sizeof(cl_mem), (void *)&bufferC);
    ret = clSetKernelArg(kernel, 3, sizeof(cl_mem), (void *)&bufferD);
    
    /* Execute OpenCL Kernel */
    ret = clEnqueueTask(command_queue, kernel, 0, NULL,NULL);
    
    /* Copy results from the memory buffer */
    ret = clEnqueueReadBuffer(command_queue, bufferA, CL_TRUE, 0,
                              1 * sizeof(pw_t),pws, 0, NULL, NULL);
    ret = clEnqueueReadBuffer(command_queue, bufferB, CL_TRUE, 0,
                              4 * sizeof(u32),salt_u32, 0, NULL, NULL);
    ret = clEnqueueReadBuffer(command_queue, bufferC, CL_TRUE, 0,
                              1 * sizeof(u32),loop_cnt_ptr, 0, NULL, NULL);
    ret = clEnqueueReadBuffer(command_queue, bufferD, CL_TRUE, 0,
                              6 * sizeof(u32),result, 0, NULL, NULL);
//    $2a$05$EIPAmlpctDvZLPDTt8iY1uzjbtJ5LSYn.1hK.gCfdOazIUxVlqXZW
    /* Display Result */
//    puts(string);
    
    memcpy(hash, salt, 7 + 22);
    BF_swap(result, 6);
    BF_encode(&hash[7+22], result, 23);
    hash[7+22+31] = '\0';
    puts(hash);
    /* Finalization */
    ret = clFlush(command_queue);
    ret = clFinish(command_queue);
    ret = clReleaseKernel(kernel);
    ret = clReleaseProgram(program);
    ret = clReleaseMemObject(bufferA);
    ret = clReleaseCommandQueue(command_queue);
    ret = clReleaseContext(context);
    
    free(source_str);
    
    return 0;
}
