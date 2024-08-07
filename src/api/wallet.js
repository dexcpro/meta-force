import { ethers } from 'ethers'
import { ElMessage } from 'element-plus'

// 连接钱包
async function checkNetwork() {
    let network;
    if (window.ethereum) {
        try {
            return window.ethereum.request({ method: 'eth_requestAccounts' });
        } catch (error) {

            if (error.info && error.info.error) {
                const errorMessage = error.info.error.data && error.info.error.data.message ? error.info.error.data.message : error.info.error.message

                ElMessage.error(errorMessage)
            } else {
                ElMessage.error('Error message not available')
            }
        }
    } else {
        ElMessage.error('请安装 MetaMask 或其他支持的钱包');
    }

}

// 获取签名
function getprovider() {
    let provider = null
    try {

        if (window.ethereum) {

            provider = new ethers.BrowserProvider(window.ethereum)

        } else {
            console.error('请安装 MetaMask 或其他支持的钱包');
        }

    } catch (error) {
        if (error.info && error.info.error) {
            const errorMessage = error.info.error.data && error.info.error.data.message ? error.info.error.data.message : error.info.error.message

            ElMessage.error(errorMessage)
        } else {
            ElMessage.error('Error message not available')
        }
    }
    return provider
}

export { checkNetwork, getprovider };