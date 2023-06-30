source_patch = "new_snd_stream_official_v2_looppoint_fix.asm"
out_path = "new_snd_stream_official_v2_looppoint_fix_eu.asm"

REPLACEMENT_MAP = {
    ######
    # standard functions
    ######
    # alloc
    "2008168": "2008168",
    # file open
    "2008210": "2008210",
    # file stream ctor/reset/clean/whatever
    "2008204": "2008204",
    # file seek
    "20082A8": "20082A8",
    # file read
    "2008254": "2008254",
    # file close
    "20082C4": "20082C4",
    # file dealloc
    "2008194": "2008194",
    # sprintf
    "0200D634": "0200d6bc",
    # euclidian division
    "0208FEA4": "0209023C",
    ######
    # Other
    ######
    # previous actor space before being removed by the patch
    "020A6A58": "020a72f8",
    # idk, but identical
    "02002CB4": "02002CB4",
    # idk, but used previously
    "020198D0": "0201996c",
    # ok. That ones coincidently point to another important address in EU...
    "0201996C": "02019a08",
    # end of the PlayBGM function (with sp handling)
    "02019AF8": "02019b94",
    # hook stop BGM
    "02019B30": "02019bcc",
    # hook change BGM
    "02019C64": "02019d00",
    # The think that was first not used, but is now used.
    "02071038": "020713d0",
    # idk
    "020743EC": "02074784",
    # same, but seemingly related. Something about channel allocation
    "020743F4": "0207478c",
    # something music info?
    "02079888": "02079c20",
    # transmit audio command to ARM7
    "0207CA24": "0207cdbc",
    # SetChannelGlobal
    "0207CA6C": "0207ce04",
    # ChannelStruct
    "022B7A30": "022b8370",
    # The same, I think? The address of the buffer
    "023B0000": "023B0000",
    # something new (finally), TMR2 (so it’s hardware timer that’s used?)
    # Memory mapped-IO. Likely identical.
    "04000108": "04000108",
    # start of arm9
    "02000000": "02000000",
    # not an address
    "FFFFFFFF": "FFFFFFFF",
    # I really don’t know, but previous localisation show it’s identical. I think.
    "20746D66": "20746D66",
    # newly used address... That’s definitivelly not in ROM.
    # No idea. Random guess
    "6C706D73": "6C706D73",
    # same, but was actually used in a previous patch
    "61746164": "61746164"

}

source_patch_file = open(source_patch)
source_patch = source_patch_file.read()
source_patch_file.close()

output = ""
first_loop = True
for potential_address in source_patch.split("0x"):
    m = potential_address.split(" ")[0].split("\n")[0]
    if len(m) == 8:
        if m in REPLACEMENT_MAP:
            output += "0x" + REPLACEMENT_MAP[m]
        else:
            print("no replacement for " + m)
            output += "0x" + m
        output += potential_address[8:]
    else:
        if not first_loop:
            output += "0x"
        output += potential_address
        first_loop = False

a = open(out_path, "w")
a.write(output)
a.close()