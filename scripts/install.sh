# Create build folder
mkdir build
cd build

# Install SourceMod
wget --input-file=http://sourcemod.net/smdrop/$SM_VERSION/sourcemod-latest-linux
tar -xzf $(cat sourcemod-latest-linux)

# Copy sp to build dir
cp -r ../addons/sourcemod/scripting addons/sourcemod
cd addons/sourcemod/scripting

# Install includes
wget "https://raw.githubusercontent.com/SlidyBat/CollisionHook/master/sourcemod/scripting/include/collisionhook.inc" -O include/collisionhook.inc
wget "https://raw.githubusercontent.com/peace-maker/DHooks2/dynhooks/sourcemod_files/scripting/include/dhooks.inc" -O include/dhooks.inc
wget "https://raw.githubusercontent.com/asherkin/TF2Items/master/pawn/tf2items.inc" -O include/tf2items.inc
wget "https://raw.githubusercontent.com/nosoop/SM-TFEconData/master/scripting/include/tf_econ_data.inc" -O include/tf_econ_data.inc
wget "https://raw.githubusercontent.com/FlaminSarge/tf2attributes/master/scripting/include/tf2attributes.inc" -O include/tf2attributes.inc
wget "https://raw.githubusercontent.com/Batfoxkid/lambda/main/lambda.inc" -O include/lambda.inc
wget "https://raw.githubusercontent.com/DoctorMcKay/sourcemod-plugins/master/scripting/include/morecolors.inc" -O include/morecolors.inc
wget "https://raw.githubusercontent.com/Batfoxkid/Text-Store/master/addons/sourcemod/scripting/include/textstore.inc" -O include/textstore.inc
#wget "https://raw.githubusercontent.com/Batfoxkid/Batfoxkid/main/addons/sourcemod/scripting/include/menus-controller.inc" -O include/menus-controller.inc

# The Big CBaseNPC Family
mkdir include/cbasenpc
mkdir include/cbasenpc/tf
mkdir include/cbasenpc/nextbot
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc.inc" -O include/cbasenpc.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/activity.inc" -O include/cbasenpc/activity.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/baseanimating.inc" -O include/cbasenpc/baseanimating.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/baseanimatingoverlay.inc" -O include/cbasenpc/baseanimatingoverlay.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/basecombatcharacter.inc" -O include/cbasenpc/basecombatcharacter.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/baseentity.inc" -O include/cbasenpc/baseentity.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/entityfactory.inc" -O include/cbasenpc/entityfactory.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/matrix.inc" -O include/cbasenpc/matrix.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nav.inc" -O include/cbasenpc/nav.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot.inc" -O include/cbasenpc/nextbot.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/util.inc" -O include/cbasenpc/util.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/tf/nav.inc" -O include/cbasenpc/tf/nav.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/behavior.inc" -O include/cbasenpc/nextbot/behavior.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/body.inc" -O include/cbasenpc/nextbot/body.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/intention.inc" -O include/cbasenpc/nextbot/intention.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/knownentity.inc" -O include/cbasenpc/nextbot/knownentity.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/locomotion.inc" -O include/cbasenpc/nextbot/locomotion.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/path.inc" -O include/cbasenpc/nextbot/path.inc
wget "https://raw.githubusercontent.com/TF2-DMB/CBaseNPC/master/scripting/include/cbasenpc/nextbot/vision.inc" -O include/cbasenpc/nextbot/vision.inc
