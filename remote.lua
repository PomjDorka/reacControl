local key = "47lmibDMrTkeU_wnQKYd9nqrwZ7ylSje2jCekTg9"

os.loadAPI("rawterm.lua")
print("Connecting to CraftOS-PC Remote...")
rawterm.connect("https://remote.craftos-pc.cc/server.lua", key)
