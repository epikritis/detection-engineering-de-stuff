# Welcome to my Detection Engineering repo!

For the lab setup, run the `de-lab-installer.sh` file to set up everything for you. You will need to modify a few things (passwords and tokens) in the `.env` files. You may find more information about the lab setup in the file `de-lab-setup.md`.

### Important to Note

This lab is designed to work with a VM that has 4 vCPU and 8 GB RAM. You may choose the amount of storage you would want to have, but keep in mind that you need about 30 GB for the OS files, and some additional storage for the data ingested by your agents.

This lab works best on a cloud environment, but this costs money. You can make a few changes and deploy it locally. For a cloud deployment, I tested this on Microsoft Azure because I could switch off my VM whenever I am not using it, thus save some compute expenses. Before selecting a cloud service provider, I strongly advise to check if you can save on compute costs by switching off the VM.

---

:bangbang: The base concept of the lab is not my original work, see credits below:

**Reference:**

Practical Threat Detection Engineering; Megan Roddie, Jason Deyalsingh, Gary J. Katz

Link to resource: https://www.packtpub.com/en-us/product/practical-threat-detection-engineering-9781801076715