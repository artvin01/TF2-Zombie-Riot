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
wget "https://raw.githubusercontent.com/FlaminSarge/tf2attributes/master/tf2attributes.inc" -O include/tf2attributes.inc
wget "https://raw.githubusercontent.com/Batfoxkid/lambda/main/lambda.inc" -O include/lambda.inc
wget "https://www.doctormckay.com/download/scripting/include/morecolors.inc" -O include/morecolors.inc
wget "https://raw.githubusercontent.com/Batfoxkid/Minecraft-TF2/logic/addons/sourcemod/scripting/include/minecraft_tf2.inc" -O include/minecraft_tf2.inc
wget "https://raw.githubusercontent.com/Batfoxkid/Text-Store/master/addons/sourcemod/scripting/include/textstore.inc" -O include/textstore.inc
wget "https://raw.githubusercontent.com/Batfoxkid/Batfoxkid/main/addons/sourcemod/scripting/include/menus-controller.inc" -O include/menus-controller.inc