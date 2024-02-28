const DvBookingFactory = artifacts.require("DvBookingFactory");
const DvBooking = artifacts.require("DvBooking");


contract("DvBooking", accounts => {
    let dvBooking;
    const costPerNight = web3.utils.toWei("0.01", "ether");



    before(async () => {

        const dvBookingFactory = await DvBookingFactory.deployed();

        dvBooking = await dvBookingFactory.issue("0x0000000000000000000000000000000000000000", "https://something", "HNK Orijent", "SN", {from: accounts[0]});
        dvBooking = await DvBooking.at(dvBooking.logs[0].args[1]);
        const costPerNight = web3.utils.toWei("0.01", "ether");
        await dvBooking.initialize(0, costPerNight,  { from: accounts[0] });
        // const totalSupply = await dvBooking._totalSupply();
        // console.log(totalSupply.toNumber());
    });

    it("should allow a user to book accommodation if dates are available", async () => {
        const checkInDate = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
        const checkOutDate = checkInDate + 86400 * 3; // Three days later
        const costPerNight = web3.utils.toWei("0.01", "ether");

        await dvBooking.book(checkInDate, checkOutDate, {
            from: accounts[0],
            value: costPerNight * 3,
        });

        const booking = await dvBooking.bookings(0);
        assert.equal(booking.user, accounts[0], "Booking was not recorded correctly.");
    });

    it("should allow a user to book accommodation if dates are available", async () => {
        const checkInDate = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
        const checkOutDate = checkInDate + 86400 * 3; // Three days later

        await dvBooking.book(checkInDate, checkOutDate, {
            from: accounts[0],
            value: costPerNight * 3,
        });

        const booking = await dvBooking.bookings(0);
        assert.equal(booking.user, accounts[0], "Booking was not recorded correctly.");
    });

    it("should not allow booking if dates are not available", async () => {
        const checkInDate = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
        const checkOutDate = checkInDate + 86400 * 3; // Three days later

        try {
            await dvBooking.book(checkInDate + 86400, checkOutDate + 86400, {
                from: accounts[0],
                value: costPerNight * 3,
            });
            assert.fail("The booking should have caused a revert due to date conflict");
        } catch (error) {
            assert.include(error.message, "revert", "The error message should contain 'revert'");
        }
    });

    it("should check if a date is booked", async () => {
        const checkInDate = Math.floor(Date.now() / 1000) + 86400; // Tomorrow
        const checkOutDate = checkInDate + 86400 * 2; // Two days later

        // Assuming a booking already exists in the test above
        const isBooked = await dvBooking.isDateBooked(checkInDate + 86400);
        assert.isTrue(isBooked, "The date should be booked");

        const isNotBooked = await dvBooking.isDateBooked(checkOutDate + 86400);
        assert.isFalse(isNotBooked, "The date should be available");
    });

    it("should handle payments correctly", async () => {
        const checkInDate = Math.floor(Date.now() / 1000) + 86400 * 5; // 5 days from now
        const checkOutDate = checkInDate + 86400 * 3; // Three days later

        const initialBalance = web3.utils.toBN(await web3.eth.getBalance(dvBooking.address));
        await dvBooking.book(checkInDate, checkOutDate, {
            from: accounts[0],
            value: costPerNight * 3,
        });
        const finalBalance = web3.utils.toBN(await web3.eth.getBalance(dvBooking.address));

        assert.equal(finalBalance.sub(initialBalance).toString(), (costPerNight * 3).toString(), "Contract did not receive the correct amount of Ether");
    });


});
