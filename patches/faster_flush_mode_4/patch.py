from typing import Callable
from ndspy.rom import NintendoDSRom
from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.handler.abstract import AbstractPatchHandler
from skytemple_files.common.util import get_binary_from_rom, read_u32

SOME_PATCH_ADDRESS = 0x0200af48
ORIGINAL_INSTRUCTION = 0xbb1402eb


class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'FasterFlushMode4'

    @property
    def description(self) -> str:
        return "Make flush mode 4 faster, avoiding issue mostly noticeable with Desmume"

    @property
    def author(self) -> str:
        return 'marius851000'

    @property
    def version(self) -> str:
        return '1.0.0'

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        arm9 = get_binary_from_rom(rom, config.bin_sections.arm9)
        if config.game_version == GAME_VERSION_EOS:
            if config.game_region == GAME_REGION_US or config.game_region == GAME_REGION_EU:
                return read_u32(arm9, SOME_PATCH_ADDRESS) == ORIGINAL_INSTRUCTION
        raise NotImplementedError()

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()
