from typing import Callable, List
from ndspy.rom import NintendoDSRom
from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.handler.abstract import AbstractPatchHandler
from skytemple_files.common.util import get_binary_from_rom, read_u32

SOME_PATCH_ADDRESS_EU = 0x020713d0
SOME_PATCH_ADDRESS_NA = 0x02071038
ORIGINAL_INSTRUCTION_EU = 0x122200eb
ORIGINAL_INSTRUCTION_NA = 0x122200eb


class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'SndStream'

    @property
    def description(self) -> str:
        return "Allow to play custom wav music with loop"

    @property
    def author(self) -> str:
        return 'irdkwia, packaged/ported to EU by marius851000'

    @property
    def version(self) -> str:
        return '0.1.0'
    
    def depends_on(self) -> List[str]:
        return ["ActorAndLevelLoader"]

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        arm9 = get_binary_from_rom(rom, config.bin_sections.arm9)
        if config.game_version == GAME_VERSION_EOS:
            if config.game_region == GAME_REGION_US:
                return read_u32(arm9, SOME_PATCH_ADDRESS_NA) == ORIGINAL_INSTRUCTION_NA
            if config.game_region == GAME_REGION_EU:
                return read_u32(arm9, SOME_PATCH_ADDRESS_EU) == ORIGINAL_INSTRUCTION_EU
        raise NotImplementedError()

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()
