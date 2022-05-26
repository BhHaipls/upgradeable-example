// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

uint256 constant DECIMALS = 18;
uint256 constant DECIMALS18 = 1e18;

uint256 constant MAX_UINT256 = type(uint256).max;
uint256 constant PERCENTAGE_100 = 100 * DECIMALS18;
uint256 constant PERCENTAGE_1 = DECIMALS18;
uint256 constant MAX_FEE_PERCENTAGE = 99 * DECIMALS18;

string constant ERROR_ACCESS_DENIED = "0x1";
string constant ERROR_NO_CONTRACT = "0x2";
string constant ERROR_NOT_AVAILABLE = "0x3";
string constant ERROR_KYC_MISSING = "0x4";
string constant ERROR_INVALID_ADDRESS = "0x5";
string constant ERROR_INCORRECT_CALL_METHOD = "0x6";
string constant ERROR_AMOUNT_IS_ZERO = "0x7";
string constant ERROR_HAVENT_ALLOCATION = "0x8";
string constant ERROR_AMOUNT_IS_MORE_TS = "0x9";
string constant ERROR_ERC20_CALL_ERROR = "0xa";
string constant ERROR_DIFF_ARR_LENGTH = "0xb";
string constant ERROR_METHOD_DISABLE = "0xc";
string constant ERROR_SEND_VALUE = "0xd";
string constant ERROR_NOT_ENOUGH_NFT_IDS = "0xe";
string constant ERROR_INCORRECT_FEE = "0xf";
string constant ERROR_WRONG_IMPLEMENT_ADDRESS = "0x10";
string constant ERROR_INVALID_SIGNER = "0x11";
string constant ERROR_NOT_FOUND = "0x12";
string constant ERROR_IS_EXISTS = "0x13";
string constant ERROR_IS_NOT_EXISTS = "0x14";
string constant ERROR_TIME_OUT = "0x15";
string constant ERROR_NFT_NOT_EXISTS = "0x16";
string constant ERROR_MINTING_COMPLETED = "0x17";
string constant ERROR_TOKEN_NOT_SUPPORTED = "0x18";
string constant ERROR_NOT_ENOUGH_NFT_FOR_SALE = "0x19";
string constant ERROR_NOT_ENOUGH_PREVIOUS_NFT = "0x1a";
string constant ERROR_FAIL = "0x1b";
string constant ERROR_MORE_THEN_MAX = "0x1c";
string constant ERROR_VESTING_NOT_START = "0x1d";
string constant ERROR_VESTING_IS_STARTED = "0x1e";
string constant ERROR_IS_SET = "0x1f";
string constant ERROR_ALREADY_CALL_METHOD = "0x20";
string constant ERROR_INCORRECT_DATE = "0x21";
string constant ERROR_IS_NOT_SALE = "0x22";
string constant ERROR_UNPREDICTABLE_MEMBER_ACTION = "0x23";
string constant ERROR_ALREADY_PAID = "0x24";
string constant ERROR_COOLDOWN_IS_NOT_OVER = "0x25";
string constant ERROR_INSUFFICIENT_AMOUNT = "0x26";
string constant ERROR_RESERVES_IS_ZERO = "0x27";
string constant ERROR_DELAY_IS_NOT_OVER = "0x28";
string constant ERROR_CONTRACT_IS_PAUSED = "0x29";
string constant ERROR_NOT_COMPROMISED = "0x2a";
string constant ERROR_INVALID_NONCE = "0x2b";

bytes32 constant KYC_CONTAINER_TYPEHASE = keccak256("Container(address sender,uint256 deadline)");

//permisionss
//WHITELIST
uint256 constant ROLE_ADMIN = 1;

uint256 constant MANAGEMENT_CAN_SET_KYC_WHITELISTED = 3;
uint256 constant MANAGEMENT_KYC_SIGNER = 4;
uint256 constant MANAGEMENT_WHITELISTED_KYC = 5;

uint256 constant SHOPS_PAYMENT_PAY_SIGNER = 21;
uint256 constant SHOPS_PAYMENT_CAN_SET_RATE = 22;
uint256 constant SHOPS_PAYMENT_CAN_SWITCH_MODE = 23;
uint256 constant SHOPS_PAYMENT_CAN_SWITCH_STATE = 24;

uint256 constant SHOPS_POOL_CAN_WITHDRAW_FOR = 31;
uint256 constant SHOPS_POOL_CAN_WITHDRAW_COMPROMISED_FUNDS = 32;

uint256 constant SHOPS_MANAGER_BLACK_LIST_PERM = 41;
uint256 constant SHOPS_MANAGER_FREEZE_LIST_PERM = 42;
uint256 constant SHOPS_MANAGER_CAN_SET_SHOP_ACCESS = 43;
uint256 constant SHOPS_MANAGER_CAN_REGISTER_REMOVE_SHOP = 44;
uint256 constant SHOPS_MANAGER_CAN_SET_COMMISION = 45;
uint256 constant SHOPS_MANAGER_CAN_SET_DELAY = 46;

//REGISTER_ADDRESS
uint256 constant CONTRACT_MANAGEMENT = 0;

uint256 constant CONTRACT_KRU_SHOPS_PAYMENT_PROCCESOR = 2;
uint256 constant CONTRACT_KRU_SHOPS_POOL = 3;
uint256 constant CONTRACT_KRU_SHOPS_MANAGER = 4;

uint256 constant CONTRACT_UNISWAP_V2_PAIR = 23;
uint256 constant CONTRACT_UNISWAP_V2_ROUTER = 24;
uint256 constant CONTRACT_UNISWAP_V2_FACTORY = 25;
uint256 constant CONTRACT_WRAPPED_KRU = 26;

uint256 constant CONTRACT_KRU_SHOPS_TRESUARY = 100;
