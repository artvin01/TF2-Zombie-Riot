import util

if "wavesets" in util.SCOPE:
    import modules.wavesets
    modules.wavesets.parse()

if "items" in util.SCOPE:
    import modules.weapon
    modules.weapon.parse()

if "skilltree" in util.SCOPE:
    import modules.skilltree
    modules.skilltree.parse()