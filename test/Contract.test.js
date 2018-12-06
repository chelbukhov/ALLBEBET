const assert = require ('assert');              // утверждения
const ganache = require ('ganache-cli');        // тестовая сеть
const Web3 = require ('web3');                  // библиотека для подключения к ефириуму

require('events').EventEmitter.defaultMaxListeners = 0;

const compiledContract = require('../build/Crowdsale.json');

const compiledToken = require('../build/ALLBEBETToken.json');

// старт тестов 01.12.2018
const addTimeToStart = 0; // время в днях до Start Crowdsale 01/12/2018

let accounts;
let contractAddress;
console.log(Date());


describe('Серия тестов для проверки функций расчета курса токена и проверки варианта Refund ...', () => {
    let web3 = new Web3(ganache.provider());      // настройка провайдера

    it('Разворачиваем контракт для тестирования...', async () => {

        accounts = await web3.eth.getAccounts();
        contract = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
            .deploy({ data: compiledContract.bytecode })
            .send({ from: accounts[0], gas: '6000000'});
    });

    it('Адрес контракта...', async () => {
        contractAddress = (await contract.options.address);
    });

    it('Получаем развернутый контракт токена...', async () => {
        //получаем адрес токена
        const tokenAddress = await contract.methods.token().call();

        //получаем развернутый ранее контракт токена по указанному адресу
        token = await new web3.eth.Contract(
        JSON.parse(compiledToken.interface),
        tokenAddress
        );
        //console.log("TokenAddress", token);
    });
    
    it('Проверка остатка токенов на адресе Crowdsale = 700 млн...', async () => {
        let myAddress = contractAddress;

        let myBalance = await token.methods.balanceOf(myAddress).call();
        myBalance = web3.utils.fromWei(myBalance, 'ether');
        assert(myBalance == 700000000);
        //console.log("CrowdsaleAddress tokens: ", myBalance);
    });

    it('Перевод эфиров на адрес Crowdsale...', async () => {
        try {
            await contract.methods.buyTokens(accounts[2]).send({
                from: accounts[2],
                gas: "1000000",
                value: 5*10**18
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });    

    it('Проверка токенов на адресе accounts[2]  5*1000=5000', async () => {

        let myBalance = await token.methods.balanceOf(accounts[2]).call();
        myBalance = web3.utils.fromWei(myBalance, 'ether');
        assert(myBalance == 5000);
        //console.log(myBalance);
    });


    it('Перевод времени до первой смены курса (45 дней)...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 45],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
    );
    });    

    it('Попытка первой смены курса...', async () => {
        try {
            await contract.methods.calcRate().send({
                from: accounts[2],
                gas: "1000000"
            });
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });    

    it('Проверка первой смены курса...', async () => {
        try {
            let newRate = await contract.methods.rate().call();
            assert(newRate = 769);
            //console.log(newRate);
        } catch (error) {
            assert(false);
            console.log(error);
        }
    }); 

    it('Перевод эфиров на адрес Crowdsale...', async () => {
        try {
            await contract.methods.buyTokens(accounts[3]).send({
                from: accounts[3],
                gas: "1000000",
                value: 5*10**18
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });    

    it('Проверка токенов на адресе accounts[3]  5*769=3845', async () => {

        let myBalance = await token.methods.balanceOf(accounts[3]).call();
        myBalance = web3.utils.fromWei(myBalance, 'ether');
        assert(myBalance == 3845);
        //console.log(myBalance);
    });

    it('Перевод времени до второй смены курса 365 дней...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 365],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
        );
    });    

    it('Проверка второй смены курса 625...', async () => {
        try {
            let newRate = await contract.methods.rate().call();
            assert(newRate = 625);
            //console.log(newRate);
        } catch (error) {
            assert(false);
            console.log(error);
        }    });    

    it('Перевод эфиров на адрес Crowdsale...', async () => {
        try {
            await contract.methods.buyTokens(accounts[4]).send({
                from: accounts[4],
                gas: "1000000",
                value: 5*10**18
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });

    it('Проверка токенов на адресе accounts[4]  5*625=3125', async () => {

        let myBalance = await token.methods.balanceOf(accounts[4]).call();
        myBalance = web3.utils.fromWei(myBalance, 'ether');
        assert(myBalance == 3125);
        //console.log(myBalance);
    });

    it('Перевод времени до окончания Crowdsale...', async () => {
        const myVal = await new Promise((resolve, reject) =>
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [60 * 60 * 24 * 370],
            id: new Date().getTime()
        }, (error, result) => error ? reject(error) : resolve(result.result))
        );
    });    

    it('finishCrowdsale - переход в стадию refund...', async () => {
        try {
            await contract.methods.finishCrowdSale().send({
                from: accounts[4],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });    


    it('Проверка баланса на account[2] менее 95 эфиров- ...', async () => {
        accBalance = await web3.eth.getBalance(accounts[2]);
        accBalance = web3.utils.fromWei(accBalance, 'ether');
        assert(accBalance < 95);
        console.log("Balance of account[2]: ", accBalance);
    });


    it('Проверка возврата средств инвесторам- выполнение функции refund...', async () => {
        try {
            await contract.methods.refund().send({
                from: accounts[2],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });    

    it('Проверка баланса на account[2] более 99 эфиров- ...', async () => {
        accBalance = await web3.eth.getBalance(accounts[2]);
        accBalance = web3.utils.fromWei(accBalance, 'ether');
        assert(accBalance > 99);
        console.log("Balance of account[2]: ", accBalance);
    });

    it('Перевод эфиров на адрес Crowdsale - должен отбить (refund)...', async () => {
        try {
            await contract.methods.buyTokens(accounts[4]).send({
                from: accounts[4],
                gas: "1000000",
                value: 5*10**18
            });
            assert(false);    
        } catch (error) {
            assert(error);
            //console.log(error);
        }
    });

});


describe('Серия тестов для проверки варианта Work ...', () => {
    let web3 = new Web3(ganache.provider());      // настройка провайдера

    it('Разворачиваем контракт для тестирования...', async () => {

        accounts = await web3.eth.getAccounts();
        contract = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
            .deploy({ data: compiledContract.bytecode })
            .send({ from: accounts[0], gas: '6000000'});
    });

    it('Адрес контракта...', async () => {
        contractAddress = (await contract.options.address);
    });

    it('Получаем развернутый контракт токена...', async () => {
        //получаем адрес токена
        const tokenAddress = await contract.methods.token().call();

        //получаем развернутый ранее контракт токена по указанному адресу
        token = await new web3.eth.Contract(
        JSON.parse(compiledToken.interface),
        tokenAddress
        );
        //console.log("TokenAddress", token);
    });

    it('Перевод эфиров на адрес Crowdsale 80 эфиров при софткапе 70...', async () => {
        try {
            await contract.methods.buyTokens(accounts[4]).send({
                from: accounts[4],
                gas: "1000000",
                value: 80*10**18
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    });

    it('finishCrowdsale - переход в стадию Work...', async () => {
        try {
            await contract.methods.finishCrowdSale().send({
                from: accounts[4],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            console.log(error);
        }
    }); 

    it('Проверка возврата средств инвесторам- выполнение функции refund - должен отбить...', async () => {
        try {
            await contract.methods.refund().send({
                from: accounts[4],
                gas: "1000000"
            });
            assert(false);    
        } catch (error) {
            assert(error);
            //console.log(error);
        }
    });  
    
    it('Проверка перевода токенов между пользователями...', async () => {
        try {
            await token.methods.transfer(accounts[5], 1000).send({
                from: accounts[4],
                gas: "1000000"
            });
            assert(true);    
        } catch (error) {
            assert(false);
            //console.log(error);
        }
    });

    it('Проверка токенов у получателя...', async () => {
        let myBalance = await token.methods.balanceOf(accounts[5]).call();
        //myBalance = web3.utils.fromWei(myBalance, 'ether');
        assert(myBalance == 1000);
    });

    it('Проверка баланса на account[9] = 100 эфиров- ...', async () => {
        accBalance = await web3.eth.getBalance(accounts[9]);
        accBalance = web3.utils.fromWei(accBalance, 'ether');
        assert(accBalance == 100);
        console.log("Balance of account[9]: ", accBalance);
    });


    it('Проверка вывода средств с баланса контракта - 10 эфиров...', async () => {
        try {
            await contract.methods.withdrawFunds(accounts[9], "10000000000000000000").send({
                from: accounts[0],
                gas: "1000000"
            });
               
        } catch (error) {
            assert(false)
            console.log(error)            
        }
    });

    it('Проверка баланса на account[9] = 110 эфиров- ...', async () => {
        accBalance = await web3.eth.getBalance(accounts[9]);
        accBalance = web3.utils.fromWei(accBalance, 'ether');
        assert(accBalance == 110);
        console.log("Balance of account[9]: ", accBalance);
    });
});
