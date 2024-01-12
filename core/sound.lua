-- Table to represent sound functionalities
Sound = {}

--- Plays a .wav audio file.
-- This function is a wrapper around the external function soundPlay.
-- It allows the playing of a .wav audio file specified by the file path argument.
-- @param filePath (string) - The path to the .wav audio file that should be played.
-- @return (boolean) Returns true if the audio file is played successfully, false otherwise.
function Sound.play(filePath)
    return soundPlay(filePath)
end
