local M = {}

-- Configuration
M.model = "base.en"
M.whisper_home = "/opt/whisper.cpp"
M.whisper_path = "/usr/bin/whisper-cli"

-- Generate unique temp file base name
M.tmp_file = vim.fn.tempname() .. "_whisper"

-- Check if whisper.cpp is properly set up
function M.check_whisper_setup()
  local model_path = M.whisper_home .. "/models/ggml-" .. M.model .. ".bin"

  local whisper_exists = vim.fn.filereadable(M.whisper_path) == 1
  local model_exists = vim.fn.filereadable(model_path) == 1

  if not whisper_exists then
    vim.notify("The 'whisper' executable was not found at " .. M.whisper_path, vim.log.levels.ERROR)
    return false
  end

  if not model_exists then
    vim.notify("The '" .. M.model .. "' model was not found at " .. model_path, vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Function to record audio
function M.record_audio()
  local audio_file = M.tmp_file .. ".wav"

  if vim.fn.executable("ffmpeg") == 1 then
    -- Start recording in background - simplified for microphone-only transcription
    local record_cmd =
      string.format("ffmpeg -f pulse -i @DEFAULT_SOURCE@ -ar 16000 -ac 1 -c:a pcm_s16le %s -y 2>/dev/null", audio_file)

    vim.notify("Recording... Press ENTER to stop", vim.log.levels.INFO)

    -- Start recording process in background
    local job_id = vim.fn.jobstart(record_cmd, {
      detach = true,
    })

    -- Wait for user input
    vim.fn.getchar()

    -- Send SIGINT (like Ctrl+C) which ffmpeg handles better
    vim.fn.jobstop(job_id)

    -- Wait for the job to actually finish before continuing
    while vim.fn.jobwait({ job_id }, 0)[1] == -1 do
      vim.wait(100) -- Wait 100ms and check again
    end

    vim.notify("Recording stopped", vim.log.levels.INFO)

    return true
  else
    vim.notify("ffmpeg command not found. Install ffmpeg package.", vim.log.levels.ERROR)
    return false
  end
end

-- Run whisper transcription
function M.transcribe()
  if not M.check_whisper_setup() then
    return
  end

  -- First record the audio
  if not M.record_audio() then
    return
  end

  local audio_file = M.tmp_file .. ".wav"
  local output_file = M.tmp_file .. ".txt"

  vim.notify("Transcribing...", vim.log.levels.INFO)

  -- Check if audio file exists and has content
  if vim.fn.filereadable(audio_file) == 0 then
    vim.notify("Audio file not found: " .. audio_file, vim.log.levels.ERROR)
    return nil
  end

  local audio_size = vim.fn.getfsize(audio_file)
  if audio_size <= 0 then
    vim.notify("Audio file is empty: " .. audio_file, vim.log.levels.ERROR)
    return nil
  end

  -- Transcribe with main whisper binary for clean output
  local cmd = string.format(
    "cd %s && %s -m models/ggml-%s.bin -f %s -otxt -of %s --no-timestamps",
    M.whisper_home,
    M.whisper_path,
    M.model,
    audio_file,
    M.tmp_file
  )

  -- Run the command and capture return code
  local result = vim.fn.system(cmd)
  local return_code = vim.v.shell_error

  if return_code ~= 0 then
    vim.notify("Whisper command failed with code " .. return_code .. ": " .. result, vim.log.levels.ERROR)
    return nil
  end

  -- Wait for output file with timeout
  local max_wait = 30 -- 30 seconds max wait
  local wait_count = 0
  while vim.fn.filereadable(output_file) == 0 and wait_count < max_wait do
    vim.wait(1000) -- Wait 1 second
    wait_count = wait_count + 1
  end

  -- Read the clean text output
  if vim.fn.filereadable(output_file) == 1 then
    local text = vim.fn.readfile(output_file)
    vim.notify("Transcription complete", vim.log.levels.INFO)
    return table.concat(text, " "):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
  else
    vim.notify("Transcription output file not found after " .. wait_count .. " seconds", vim.log.levels.ERROR)
    return nil
  end
end

-- Insert transcription in insert mode
function M.insert_transcription()
  local mode = vim.api.nvim_get_mode().mode
  local text = M.transcribe()

  if text then
    if mode == "i" or mode == "a" then
      vim.api.nvim_put({ text }, "", false, true)
    else
      vim.api.nvim_put({ text }, "c", true, true)
    end
  end
end

-- Replace selection with transcription in visual mode
function M.replace_selection()
  local text = M.transcribe()

  if text then
    vim.api.nvim_command("normal! c")
    vim.api.nvim_put({ text }, "", false, true)
  end
end

-- Normal mode transcription
function M.normal_transcription()
  local text = M.transcribe()

  if text then
    vim.api.nvim_put({ text }, "c", true, true)
  end
end

return M
