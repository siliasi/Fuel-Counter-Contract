#!/bin/bash

GREEN='\033[1;32m'
PURPLE='\033[1;35m'
NC='\033[0m'

echo -e "${GREEN}Downloading and running the Fuel Network installer...${NC}"
echo
curl https://install.fuel.network | sh
echo

export PATH="$HOME/.fuelup/bin:$PATH"
sleep 2
echo

echo -e "${GREEN}Waiting 5 sec...${NC}"
source /home/codespace/.bashrc
sleep 5

echo -e "${GREEN}Setting the latest toolchain as default...${NC}"
echo
fuelup default latest
echo

mkdir zunxbt && cd zunxbt
echo

echo -e "${GREEN}Creating a new Forc project named 'zun'...${NC}"
echo
forc new zun
echo

cat <<EOF > zun/src/main.sw
contract;

storage {
    counter: u64 = 0,
}

abi Counter {
    #[storage(read, write)]
    fn increment();

    #[storage(read)]
    fn count() -> u64;
}

impl Counter for Contract {
    #[storage(read)]
    fn count() -> u64 {
        storage.counter.read()
    }

    #[storage(read, write)]
    fn increment() {
        let incremented = storage.counter.read() + 1;
        storage.counter.write(incremented);
    }
}
EOF

echo

cd zun
echo

echo -e "${GREEN}Building the Forc project...${NC}"
echo
forc build
echo

echo -e "${PURPLE}During Wallet Import, the mnemonic phrases and passwords will not be shown on terminal${NC}"
echo
while true; do
    read -p "Understand? (y/n): " response
    if [[ "$response" == "y" ]]; then
        break
    else
        echo "Please read the statement carefully and confirm by typing 'y'."
    fi
done

echo

echo -e "${GREEN}Importing the wallet...${NC}"
echo
forc wallet import
echo

echo -e "${GREEN}Deploying the project to the testnet...${NC}"
echo
forc deploy --testnet
echo
