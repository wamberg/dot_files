local M = {}

-- Configuration
M.model = "base.en"
M.whisper_home = "/opt/whisper.cpp"
M.whisper_path = "/opt/whisper.cpp/build/bin/whisper-cli"

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

  if vim.fn.executable("rec") == 1 then
    -- Start recording in background
    local record_cmd = string.format("rec -q -t wav %s rate 16k channels 1 2>/dev/null", audio_file)

    vim.notify("Recording... Press ENTER to stop", vim.log.levels.INFO)

    -- Start recording process in background
    local job_id = vim.fn.jobstart(record_cmd, {
      detach = true,
    })

    -- Wait for user input
    vim.fn.getchar()

    -- Stop the recording job
    vim.fn.jobstop(job_id)
    vim.notify("Recording stopped", vim.log.levels.INFO)

    return true
  else
    vim.notify("SoX 'rec' command not found. Install SoX package.", vim.log.levels.ERROR)
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

  -- Transcribe with main whisper binary for clean output
  local cmd = string.format(
    "cd %s && %s -m models/ggml-%s.bin -f %s -otxt -of %s --no-timestamps 2> /dev/null",
    M.whisper_home,
    M.whisper_path,
    M.model,
    audio_file,
    M.tmp_file
  )

  -- Run the command
  vim.fn.system(cmd)

  -- Read the clean text output
  if vim.fn.filereadable(output_file) == 1 then
    local text = vim.fn.readfile(output_file)
    vim.notify("Transcription complete", vim.log.levels.INFO)
    return table.concat(text, " "):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
  else
    vim.notify("Transcription output file not found", vim.log.levels.ERROR)
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
