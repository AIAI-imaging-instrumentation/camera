classdef Camera < handle

    properties (Constant = true, Hidden=true, SetAccess='immutable')

        LIB = 'ueyealias';
        IS_SET_TRIGGER_SOFTWARE = hex2dec('1008');
        IS_CM_MONO16 = 28;

        IS_CM_MONO10 = 34;

        IS_WAIT = hex2dec('0001')
        IS_DONT_WAIT = hex2dec('0000')
        IS_EXPOSURE_CMD_GET_CAPS                        = 1
        IS_EXPOSURE_CMD_GET_EXPOSURE_DEFAULT            = 2
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MIN          = 3
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MAX          = 4
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_INC          = 5
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE              = 6
        IS_EXPOSURE_CMD_GET_EXPOSURE                    = 7
        IS_EXPOSURE_CMD_SET_EXPOSURE                    = 12
        IS_AOI_IMAGE_SET_AOI                            = hex2dec('0001')
        IS_AOI_IMAGE_GET_AOI                            = hex2dec('0002')
        IS_PIXELCLOCK_CMD_GET = 5
        IS_PIXELCLOCK_CMD_SET = 6
        IS_PIXELCLOCK_CMD_GET_RANGE = 3
        IS_PIXELCLOCK_CMD_GET_NUMBER = 1
        IS_PIXELCLOCK_CMD_GET_LIST = 2
        IS_CAPTURE_STATUS = hex2dec('0003');
    end

    properties
        hid;
        imagebufferpointer;
        imagebufferpid;
        pixelclock;
        allowedpixelclock;
        exposure;
        aoi;
        exposurerange;
        framerate;
        frameraterange;
        pausetime;
    end

    methods

        function obj = Camera(hid)

            if ismac()
                error('not support');
            elseif ispc()
                libname = 'uc480_64.dll';
            else
                libname = '/usr/lib/libueye_64.so';
            end

            if ~libisloaded(obj.LIB)
                loadlibrary(libname, 'minprototype', 'alias', obj.LIB)
            end

            hidptr = libpointer('uint32Ptr', uint32(hid));
            out = calllib(obj.LIB, 'is_InitCamera', hidptr, libpointer());
            if out == 3
                error(['UEYECamera:is_InitCamera', 'Code 3: An attempt to ', ...
                       'initialize or select the camera failed (no camera ', ...
                       'connect or initialization error). Is the camera already connected?'])
            elseif out ~= 0
                error('UEYECamera:is_InitCamera', sprintf('Code %d', out));
            end
            try
                assert(out == 0);
                obj.hid = hidptr.Value;
                out = obj.callliberrcheck(obj.LIB, 'is_SetExternalTrigger', obj.hid, obj.IS_SET_TRIGGER_SOFTWARE);
                assert(out == 0);
                out = obj.callliberrcheck(obj.LIB, 'is_SetExternalTrigger', obj.hid, obj.IS_SET_TRIGGER_SOFTWARE);
                assert(out == 0);

                out = obj.callliberrcheck(obj.LIB, 'is_SetColorMode', obj.hid, obj.IS_CM_MONO10);

                assert(out == 0);
                obj.setbuffer();
            catch ME
                obj.callliberrcheck(obj.LIB, 'is_ExitCamera', obj.hid);

                unloadlibrary(obj.LIB);
                rethrow(ME);
            end
            obj.pausetime = 0;
            pause(obj.pausetime);
        end
        
        function updatebuffer(obj)
            obj.unsetbuffer();
            obj.setbuffer();
            pause(obj.pausetime);
        end
        
        function unsetbuffer(obj)
            out = calllib(obj.LIB, 'is_FreeImageMem', obj.hid, obj.imagebufferpointer, obj.imagebufferpid);
            assert(out == 0);
            pause(obj.pausetime);
        end
        
        function setbuffer(obj)

            obj.imagebufferpointer = libpointer('int8Ptr', zeros(obj.aoi(3) * 2, obj.aoi(4), 'int8'));

            pid = libpointer('int32Ptr', int32(0));
            out = obj.callliberrcheck(obj.LIB, 'is_SetAllocatedImageMem', obj.hid, int32(obj.aoi(3)), int32(obj.aoi(4)), int32(16), obj.imagebufferpointer, pid);
            assert(out == 0);
            obj.imagebufferpid = pid.Value;
            out = obj.callliberrcheck(obj.LIB, 'is_SetImageMem', obj.hid, obj.imagebufferpointer, obj.imagebufferpid);
            assert(out == 0);

            try
                obj.capture;
            end
            pause(obj.pausetime);

        end

        function img = capture(obj)
            out = obj.callliberrcheck(obj.LIB, 'is_FreezeVideo', obj.hid, obj.IS_WAIT);

            assert(out == 0);
            img = reshape(typecast(obj.imagebufferpointer.Value(:), 'uint16'), [obj.aoi(3), obj.aoi(4)]);
        end

        function delete(obj)

            obj.unsetbuffer()
            obj.callliberrcheck(obj.LIB, 'is_ExitCamera', obj.hid);

            unloadlibrary(obj.LIB);
        end

        function out = get.pixelclock(obj)
            pcPtr = libpointer('voidPtr', uint32(0));
            returncode = obj.callliberrcheck(obj.LIB, 'is_PixelClock', obj.hid, obj.IS_PIXELCLOCK_CMD_GET, pcPtr, 4);
            assert(returncode == 0);
            out = pcPtr.Value;
            pause(obj.pausetime);
        end

        function set.pixelclock(obj, newval)
            % assert(ismember(newval, obj.allowedpixelclock));
            returncode = obj.callliberrcheck(obj.LIB, 'is_PixelClock', obj.hid, obj.IS_PIXELCLOCK_CMD_SET, uint32(newval), 4);
            assert(returncode == 0);
            pause(obj.pausetime);
        end

        function out = get.allowedpixelclock(obj)
            npcPtr = libpointer('voidPtr', uint32(0));
            returncode = obj.callliberrcheck(obj.LIB, 'is_PixelClock', obj.hid, obj.IS_PIXELCLOCK_CMD_GET_NUMBER, npcPtr, 4);
            assert(returncode == 0);
            pcPtr = libpointer('voidPtr', uint32(zeros(npcPtr.Value, 1)));
            returncode = obj.callliberrcheck(obj.LIB, 'is_PixelClock', obj.hid, obj.IS_PIXELCLOCK_CMD_GET_LIST, pcPtr, 4 * npcPtr.Value);
            assert(returncode == 0);
            
            out = pcPtr.Value;
            pause(obj.pausetime);
        end

        function out = get.exposure(obj)
            ePtr = libpointer('voidPtr', double(0));
            returncode = obj.callliberrcheck(obj.LIB, 'is_Exposure', obj.hid, obj.IS_EXPOSURE_CMD_GET_EXPOSURE, ePtr, 8);
            assert(returncode == 0);
            out = ePtr.Value;
            pause(obj.pausetime);
        end

        function set.exposure(obj, newval)
            %assert(ismember(int64(newval), obj.allowedexposure));
            exposurerange = obj.exposurerange;
            if ~(newval >= exposurerange(1) && newval <= exposurerange(3))
                error('Camera:set.exposure. Exposure outside allowed range');
            end
            returncode = obj.callliberrcheck(obj.LIB, 'is_Exposure', obj.hid, obj.IS_EXPOSURE_CMD_SET_EXPOSURE, newval, 8);
            assert(returncode == 0);
            pause(obj.pausetime);
        end

        function out = get.exposurerange(obj)
                rangeparams = [0, 0, 0];
                i = 1;
                for cmd = [obj.IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MIN, ...
                           obj.IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_INC, ...
                           obj.IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MAX]
                    ePtr = libpointer('voidPtr', double(0));
                    returncode = obj.callliberrcheck(obj.LIB, 'is_Exposure', obj.hid, cmd, ePtr, 8);
                    assert(returncode == 0);
                    rangeparams(i) = ePtr.Value;
                    i = i + 1;
                end
                out = rangeparams;
                pause(obj.pausetime);

        end

        function out = get.aoi(obj)
            s = libstruct('IS_RECT', struct('s32X', int32(0), 's32Y', int32(0), 's32Width', int32(0), 's32Height', int32(0)));
            % rectPtr = libpointer('voidPtr', s);
            % rectPtr = libpointer('voidPtr', int32([0, 0, 0, 0]));
            returncode = obj.callliberrcheck(obj.LIB, 'is_AOI', obj.hid, obj.IS_AOI_IMAGE_GET_AOI, s, structsize(s));
            assert(returncode == 0);
            out = [s.s32X, s.s32Y, s.s32Width, s.s32Height];
            pause(obj.pausetime);
        end

        function set.aoi(obj, rect)
            rectStruct = libstruct('IS_RECT', struct('s32X', int32(rect(1)), 's32Y', int32(rect(2)), 's32Width', int32(rect(3)), 's32Height', int32(rect(4))));
            returncode = obj.callliberrcheck(obj.LIB, 'is_AOI', obj.hid, obj.IS_AOI_IMAGE_SET_AOI, rectStruct, structsize(rectStruct));
            assert(returncode == 0);
            obj.updatebuffer();
            pause(obj.pausetime);
        end

        function out = get.framerate(obj)
            frameratePtr = libpointer('doublePtr', double(0));
            returncode = obj.callliberrcheck(obj.LIB, 'is_GetFramesPerSecond', obj.hid, frameratePtr);
            assert(returncode == 0);
            out = frameratePtr.Value;
            pause(obj.pausetime);
        end

        function set.framerate(obj, newval)
            frameraterange = obj.frameraterange;
            if ~(newval >= frameraterange(1) && newval <= frameraterange(2))
                error('Camera:set.framerate. Framerate outside allowed range');
            end
            returncode = obj.callliberrcheck(obj.LIB, 'is_SetFrameRate', obj.hid, newval, libpointer('doublePtr', double(0)));
            assert(returncode == 0);
            pause(obj.pausetime);
        end

        function out = get.frameraterange(obj)
            minPtr = libpointer('doublePtr', double(0));
            maxPtr = libpointer('doublePtr', double(0));
            intPtr = libpointer('doublePtr', double(0));
            returncode = obj.callliberrcheck(obj.LIB, 'is_GetFrameTimeRange', obj.hid, minPtr, maxPtr, intPtr);
            assert(returncode == 0);
            out = [1 / maxPtr.Value, 1 / minPtr.Value];
            pause(obj.pausetime);
        end

        function out = IsVideoFinish(obj)
            pbo = libpointer('intPtr', obj.IS_CAPTURE_STATUS);
            obj.callliberrcheck(obj.LIB, 'is_IsVideoFinish', obj.hid, pbo);
            out = pbo.Value;
        end

        function out = callliberrcheck(obj, varargin)
            out = calllib(varargin{:});
            if out == 0
                return
            else
                pErr = libpointer('int32Ptr', int32(0));
                ppcErr = libpointer('stringPtrPtr', {''});
                out = calllib(obj.LIB, 'is_GetError', obj.hid, pErr, ppcErr);
                if out == 0
                    error(strcat('UEYECamera:', varargin{2}), sprintf('%s Error Code %d: %s', varargin{2}, pErr.Value, ppcErr.Value{1}));
                else
                    error('UEYECamera:is_GetError', sprintf('Code %d', out));
                end
            end
        end
            
   end

end
        
