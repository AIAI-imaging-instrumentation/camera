#include <stdint.h>

        // aliases for common Win32 types
        typedef int32_t           BOOLEAN;
        typedef int32_t           BOOL;
        typedef int32_t           INT;
        typedef uint32_t          UINT;
        typedef int32_t           LONG;
        typedef void              VOID;
        typedef void*             LPVOID;
        typedef uint32_t          ULONG;

        typedef uint64_t          UINT64;
        //typedef int64_t           __int64;
        typedef int64_t           LONGLONG;
        typedef uint32_t          DWORD;
        typedef uint16_t          WORD;

        typedef unsigned char     BYTE;
        typedef char              CHAR;
        typedef char              TCHAR;
        typedef unsigned char     UCHAR;

        typedef int8_t*           LPTSTR;
        typedef const int8_t*     LPCTSTR;
        typedef const int8_t*     LPCSTR;
        typedef uint32_t          WPARAM;
        typedef uint32_t          LPARAM;
        typedef uint32_t          LRESULT;
        typedef uint32_t          HRESULT;

        typedef void*             HWND;
        typedef void*             HGLOBAL;
        typedef void*             HINSTANCE;
        typedef void*             HDC;
        typedef void*             HMODULE;
        typedef void*             HKEY;
        typedef void*             HANDLE;

        typedef BYTE*             LPBYTE;
        typedef DWORD*            PDWORD;
        typedef VOID*             PVOID;
        typedef CHAR*             PCHAR;



// ----------------------------------------------------------------------------
// Typedefs
// ----------------------------------------------------------------------------
typedef DWORD   HCAM;
#define HCAM_DEFINED




typedef DWORD   HFALC;
#define HFALC_DEFINED
typedef struct
{
    INT s32X;
    INT s32Y;
    INT s32Width;
    INT s32Height;
} IS_RECT;

//UINT IS_RECT_SIZE = sizeof(IS_RECT);

INT is_InitCamera                  (HCAM* phCam, HWND hWnd);
INT is_ExitCamera                  (HCAM hCam);
INT   is_SetExternalTrigger     (HCAM hCam, INT nTriggerMode);
INT   is_SetDisplayMode         (HCAM hCam, INT Mode);
INT   is_SetColorMode           (HCAM hCam, INT Mode);
INT   is_SetAllocatedImageMem   (HCAM hCam, INT width, INT height, INT bitspixel, char* pcImgMem, int* pid);
INT   is_SetImageMem            (HCAM hCam, char* pcMem, int id);
INT   is_FreeImageMem           (HCAM hCam, char* pcMem, int id);
INT   is_FreezeVideo            (HCAM hCam, INT Wait);
INT is_PixelClock(UINT hCam, UINT nCommand, void* pParam, UINT cbSizeOfParam);
INT is_GetFramesPerSecond          (HCAM hCam, double *dblFPS);
INT is_GetFrameTimeRange           (HCAM hCam, double *min, double *max, double *intervall);
INT is_SetFrameRate                (HCAM hCam, double FPS, double* newFPS);
INT is_Exposure(HCAM hCam, UINT nCommand, void* pParam, UINT cbSizeOfParam);
INT is_AOI(HCAM hCam, UINT nCommand, void *pParam, UINT SizeOfParam);
INT is_GetError (HCAM hCam, INT* pErr, char**  ppcErr);
INT is_IsVideoFinish(HCAM hCam, INT* pbo);
