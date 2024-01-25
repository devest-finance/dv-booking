const DvBooking = artifacts.require("DvBooking");
const DvBookingFactory = artifacts.require("DvBookingFactory");

module.exports = function(deployer) {
  if (deployer.network === 'development') {
      deployer.deploy(DvBookingFactory)
          .then(() => DvBookingFactory.deployed())
          .then(async _instance => {
                await _instance.setFee(0, 0);
          });
  } else {
      deployer.deploy(DvBookingFactory)
          .then(() => DvBookingFactory.deployed())
          .then(async _instance => {
              //await _instance.setFee(0, 0);
          });
  }
};
