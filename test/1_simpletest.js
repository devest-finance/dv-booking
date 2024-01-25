const DvBookingFactory = artifacts.require("DvBookingFactory");
const DvBooking = artifacts.require("DvBooking");
// import * as ERC20Mock from "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

const ERC20Mock = artifacts.require("@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol"); // This is a mock ERC20 token for testing

contract("OrderBook", accounts => {
    let dvBooking;
    let token;

    before(async () => {
        const dvBookingFactory = await DvBookingFactory.deployed();

        token = await ERC20Mock.new("Test Token", "TKO", 10000, accounts[0]); // Give account[0] 10000 tokens for testing
        await token.transfer(accounts[1], 1000, {from: accounts[0]}); // Give account[1] 1000 tokens for testing

        dv = await dvBookingFactory.issue(token.address, "https://something", "HNK Orijent", "SN", { from: accounts[0] });
        dvBooking = await DvBooking.at(dvBooking.logs[0].args[1]);
        await dvBooking.initialize(0, 100, 5, { from: accounts[0] });
        const totalSupply = await dvBooking._totalSupply();
        console.log(totalSupply.toNumber());
    });

    it("purchase tickets", async () => {
        await token.approve(dvBooking.address, 1000, {from: accounts[1]});
        await dvBooking.book(["26-01-2024", "27-01-2024"], {from: accounts[1]});

        const balance = await dvBooking.balanceOf(accounts[1]);
        assert.equal(balance.toNumber(), 1);

        const ownerOfNumber2 = await dvBooking.ownerOf(2);
        assert.equal(ownerOfNumber2, accounts[1]);
    });

    // it("Ticket fee was collected and transferred to owner", async () => {
    //     // check balance on contract
    //     const balance = await token.balanceOf(accounts[0]);
    //
    //     // withdraw
    //     await dvTicket.withdraw({from: accounts[0]});
    //
    //     // check balance on owner
    //     const balanceAfterWithdraw = await token.balanceOf(accounts[0]);
    //     assert.equal(balanceAfterWithdraw.toNumber(), balance.toNumber() + 5);
    // });

});
