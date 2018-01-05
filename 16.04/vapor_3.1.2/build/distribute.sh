echo "📦  Updating Swift packages..."
swift package update

echo "📦  Determining latest Git tag..."
TAG=$(git describe --abbrev=0 --tags);
git checkout $TAG;

echo "📦  Updating compiled version to $TAG..."
cat ./Sources/Executable/main.swift | \
    awk -v tag="$TAG" '/let version = "master"/ { printf "let version = \"%s\"\n", tag; next } 1' > .tmp && \
    mv .tmp Sources/Executable/main.swift;

echo "📦  Building..."
swift build -c release -Xswiftc -static-stdlib # --static-swift-stdlib

echo "📦  Creating package..."
EXEC_NAME="vapor"
if [[ $TAG == *"beta"* ]]; then
	echo "Beta package detected..."
	EXEC_NAME="vapor-beta"
fi

PACKAGE_NAME="vapor-toolbox-$TAG"
mkdir -p ./$PACKAGE_NAME

README="./$PACKAGE_NAME/README.txt"

echo "Manual Install Instructions for Vapor Toolbox v$TAG" > $README
echo "" >> $README
echo "- Move *.dylib files into /usr/local/lib" >> $README
echo "- Move executable $EXEC_NAME into /usr/local/bin" >> $README
echo "- Type '$EXEC_NAME --help' into terminal to verify installation" >> $README

cp .build/release/Executable ./$PACKAGE_NAME/$EXEC_NAME
# cp .build/release/*.dylib ./$PACKAGE_NAME/

tar -cvzf macOS-sierra.tar.gz ./$PACKAGE_NAME

echo "📦  Drag and drop $PWD/macOS-sierra.tar.gz into https://github.com/vapor/toolbox/releases/edit/$TAG"

while true; do
    read -p "Have you finished uploading? [y/n]" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "📦 Generating Ruby script\n\n\n"
HASH=$(shasum -a 256 macOS-sierra.tar.gz | cut -d " " -f 1)
curl -sO https://raw.githubusercontent.com/vapor/homebrew-tap/master/vapor.rb

cat vapor.rb | awk -v tag="$TAG" -v hash="$HASH" '/version "*"/ { printf " version \"%s\"\n", tag; next }/sha256/ { printf " sha256 \"%s\"\n", hash; next } 1' > .tmp && \
mv .tmp vapor.rb
cat vapor.rb

echo "\n\n\n📦 Copy and paste the Ruby script above into https://github.com/vapor/homebrew-tap/edit/master/vapor.rb

while true; do
    read -p "Have you opened a pull request? [y/n]" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

rm -rf macOS-sierra.tar.gz
rm -rf $PACKAGE_NAME
rm vapor.rb
git reset --hard HEAD
git checkout master
