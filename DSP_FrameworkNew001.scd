/*

START AGAIN


List of sources, dsp, store in array, make as horzontal blocks, make fancy lines
Ins can be live or signal have a new menu appear for signals
outs click to change channel
Start with ins, outs and empty dsp banks
Separate panel with presets, ins/sources, out channels
Use autogui

Synthesis sources should be full on developed synths


All arg values should be 0-1 and then mapped in SC
Store presets with synthdef as variants
A way to capture these later
Get names of presets and fill an array and permanance
Can store presets either manually with the SynthDef as variants
Or use the Object.writeArchive(Archive.archiveDir/ then in the
addSynthDefFunk load a hardcoded path Archive.archiveDir

Make this for myself, and later decide if we pass to students

way to distinguish source, dsp, mod

Controlers in to supercollider
Supercollider sends control data to processing for visualization


PRESETS
q[\synthdefs][\petalsOfResonance][\presets] = (
	happy:(
		amp:0.1,
		ringL1:7.3
))
Object.writeArchive(Archive.archiveDir++"synthdefname"++"_presets");
maybe store with date so you dont override
use variants to populate the dictionary, check for duplicates
*/
