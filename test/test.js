const HelloWorldInstance = await HelloWorld.deployed();
await HelloWorldInstance.sayHello.call();
// HelloWorld.deployed().then(i=>i.sayHello());
// MetaCoin.deployed().then(i=>i.sendCoin("0x56D6F9e32f326E85934c7843861B0E36561Ed4d7",2));
const metaCoinInstance = await MetaCoin.deployed();
(await metaCoinInstance.getBalance.call("0x80F3166f7626aFA1edA03606218993Fb9d372bF3")).toNumber();
await metaCoinInstance.transfer.call("0x80F3166f7626aFA1edA03606218993Fb9d372bF3",2);
