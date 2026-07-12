# nTop Fluids on Your GPU Server
Run nTop Flow Analysis and Aircraft Flow Analysis blocks on an SSH server, directly integrated into nTop!

## How it Works
Although the inputs for Regular and Aircraft Flow Analysis are different, the same procedure takes place:

1. You define input parameters in the nTop block
2. The relevant geometry and input parameters, along with a notebook containing the actual analysis, are uploaded to the server
3. The server runs the notebook and exports its result
4. The result is downloaded and imported into your notebook

> Results from this system behave and display exactly the same as results from the regular Flow Analysis blocks

## Choosing a Vast.ai Instance
Vast.ai is an online marketplace that lets you rent GPU servers and pay by the second. Although there are many sites that do the same thing, this is the service I wrote and tested for.

You can get started with just $5, and I already have a public template for nTop Automate that you can find [here](https://cloud.vast.ai?ref_id=571287&template_id=fb94aa2b2faf08c305ce99b6963c5010).

When choosing a server, I have found that there are a few specs that make a huge difference in how fast the simulation runs.

> Note: nTop currently only supports single GPU setups, so you can filter your search to only include single GPUs

### GPU FLOPS and VRAM
Although the more VRAM (video RAM) the GPU has the bigger the simulations you can run, I have found that prioritizing the GPU's FLOPS (floating-point operations per second) over VRAM produces better results. There are many data center GPUs available, which have more VRAM, but I would recommend using a gaming or workstation GPU with more FLOPS.

There are plenty of servers for rent with 1 RTX 4090, which I find is a good balance between VRAM, FLOPS, and price.

### CPU
Although the GPU spec is the main event, the CPU performance can vary greatly between options. Keep in mind that the preprocessing steps for a Flow Analysis rely heavily on CPU performance, so avoid instances that have a low core count or slower CPUs.

### Network
The input files have to be uploaded, and the result has to be downloaded, every time. Choosing an instance with decent network speeds can make a significant difference. You don't need to prioritize speed excessively, but if the instance has a network speed less than around 150-200 Mbps it should be avoided.

## Running the Blocks
Once you have your server, running the system can be as simple as downloading this repository, setting up your SSH key, and using the blocks as normal!

### Generating an SSH key
To connect to your instance, you need an SSH key. A key can be generated using the `puttygen.exe` tool included in the `pipeline` folder. Name the private key **key.ppk**, put it in the `pipeline` folder, and add the public key to your server's authorized_keys. For ease of use with Vast.ai, you can add your public key to your account settings and it will automatically be injected into new instances you create.

### Import and Run!
Once you have your instance active and your key in place, you can import the custom block into nTop using `ctrl+i`.

The nTop file with the custom block is either `RegCloudExchanger.ntop` or `AircraftCloudExchanger.ntop` for a Regular or Aircraft Flow Analysis respectively. Both files are in the `pipeline` folder.

With the block imported you can just fill out the inputs and every step will run automatically.

### A couple quirks to keep in mind
I am using the PuTTY binaries to handle SSH because they run reliably in wine. This results in a couple quirks with key importing and host fingerprint verification:

1. The keys are handled using `pageant.exe`. When you run the block for the first time with the `SSH Key Imported` box unchecked, pageant will run in the background, and you will be prompted to enter the key password if applicable. To continue, you need to **Check the `SSH Key Imported` box and run the block again!** Running pageant will sometimes block the rest of the script from executing.

> Be sure to uncheck the `SSH Key Imported` box every time pageant is not running

2. In order to confirm the host's fingerprint and accessibility, the script will attempt to connect to the server using PuTTY in another window. When you run the block for the first time with the `Known Server` box unchecked, a popup asking to confirm the fingerprint will show. Once PuTTY successfully connects, you may close the PuTTY window to continue. You can then leave the `Known Server` box checked.

> Be sure to uncheck the `Known Server` box every time the server is new
