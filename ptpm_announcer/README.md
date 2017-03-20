# ptpm_announcer
Resource is part of [PTPM/MTASA]([https://github.com/PTPM/MTASA):  © PTPM Community (https://PTPM.uk), 2017

Voice acting: © onemunki, 2017. Commissioned by PTPM Community (https://PTPM.uk).


## Technical notes on handling audio
* The `<file>`-definitions in `meta.xml` have been given a new, proprietary attribute: `audiolength`. This value
 of this attribute is the length of the audio file in milliseconds. Adobe Audition can be used to reliably find 
 out the exact length of an audio file. The length is only used for the queueing of sound files. 
  
 * Handling one file with raw audio material can best be handled as follows:
    * Open the file in Adobe Audition
    * Use the "Diagnostics" toolkit to define silences as: Signal <65db, for more than 500ms. Define audio as >60db
     for more than 25ms.
    * For Effect, choose "Mark Audio". His scan. Adobe will now find all "bits" or lines of audio.
    * Once this process is completed, go to the tab "Markers". Double click on a marker to play that specific bit.
    * Use this tool to classify bits, and find the best ones. The "marker name" will be the exported file name. Use 
    any notes in the "Description" field.
    * Once completed, select all desired markers for export. Right click, then "Export Audio of Selected Range Markers". Use
    the following configuration for optimal compression:
    
    ```
    Export as MP3
    Sample rate 44khz
    Mono channel
    16 bit depth
    VBR @ lowest bitrate
    ```
    