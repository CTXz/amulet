local root = am.root_audio_node()

am._register_pre_frame_func(function()
    root:remove_all()
end)

function am.schedule_audio(audio_node)
    root:add(audio_node)
end

local buffer_cache = {}
setmetatable(buffer_cache, {__mode = "v"})

local
function play_file(file, loop, pitch, gain)
    pitch = pitch or 1
    gain = gain or 1
    local buf = buffer_cache[file]
    if not buf then
        buf = am.load_audio(file)
        buffer_cache[file] = buf
    end
    local audio_node = am.track(buf, loop, pitch, gain)
    return am.play(audio_node)
end

local
function play_seed(seed, loop, pitch, gain)
    pitch = pitch or 1
    gain = gain or 1
    local buf = buffer_cache[seed]
    if not buf then
        buf = am.sfxr_synth(seed)
        buffer_cache[seed] = buf
    end
    local audio_node = am.track(buf, loop, pitch, gain)
    return am.play(audio_node)
end

function am.play(arg1, arg2, arg3, arg4)
    local t = type(arg1)
    if t == "string" then
        return play_file(arg1, arg2, arg3, arg4)
    elseif t == "number" then
        return play_seed(arg1, arg2, arg3, arg4)
    else
        local audio_node = arg1
        local keep = arg2
        if keep then
            return function()
                am.schedule_audio(audio_node)
            end
        else
            return function()
                if not audio_node.finished then
                    am.schedule_audio(audio_node)
                else
                    return true
                end
            end
        end
    end
end
