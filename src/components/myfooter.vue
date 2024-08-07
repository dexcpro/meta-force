<template>
  <div class="footer">
    <div class="main">
      <div class="logo">{{ name }}</div>
      <span v-if="address" class="logo">{{ address.substring(0, 4).toUpperCase() + "..." + address.substring(address.length - 4).toUpperCase() }}</span>
    </div>
  </div>
</template>

<script>
import store from "./../store";
import { axiosInstance } from "@/api/post";
import { ethers } from "ethers";
import { mapState } from "vuex";
import { checkNetwork } from "@/api/wallet";
import eruda from "eruda";
export default {
  name: "MyFooter",
  computed: {
    ...mapState(["id", "address"]),
  },
  components: {},
  data() {
    return {
      add: null,
      name: "META-FORCE",
    };
  },
  methods: {
    async wallet() {
      try {
        if (window.ethereum) {
          store.commit("setFullscreenLoading", true);
          if (!window.ethereum.isBitKeep) {
            store.commit("setFullscreenLoading", false);
            this.$alert("仅支持Bitget Wallet钱包使用", "提示", {
              showClose: false,
              showConfirmButton: false,
              center: true,
            });
            return;
          }
          //   eruda.init();

          window.ethereum.removeAllListeners();
          window.ethereum.on("disconnect", this.wallet);
          window.ethereum.on("chainChanged", this.wallet);
          window.ethereum.on("accountsChanged", this.wallet);
          let arr = await checkNetwork();
          let chainId = parseInt(await ethereum.request({ method: "eth_chainId" }));

          store.commit("setId", chainId);
          if (chainId != 137) {
            await window.ethereum.request({
              method: "wallet_switchEthereumChain",
              params: [{ chainId: ethers.toBeHex("137") }], // `chainId` 需要以十六进制字符串格式传递
            });
          }
          store.commit("setAddress", arr[0]);
          this.$emit("sendData");
          console.log(window.ethereum);
        }

        // 这里应该有超时才对
      } catch (error) {
        this.$message.error(error.message);
        store.commit("setId", null);
        store.commit("setAddress", null);
        store.commit("setFullscreenLoading", false);
      }
    },
  },
  mounted() {
    //
    this.wallet();
  },
};
</script>
<style scoped>
.logo {
  font-weight: bold;
}
.footer {
  display: flex;
  width: 100vw;
  height: 10vh;
  align-items: center; /* 垂直居中 */

  /* opacity: 0.3; */
}
.footer .main {
  width: 90vw;
  color: aliceblue;
  margin: auto;
  display: flex;
  flex-wrap: nowrap;
  justify-content: space-between; /* 左右两边分布 */
  align-items: center; /* 上下居中 */
}
/* .button button[data-size='sm'] {
		background: floralwhite !important;
	} */
@media (min-width: 625px) {
  .footer {
    height: 72.1875px;
  }
}
</style>
<style>
wui-flex > wui-text {
  color: aliceblue;
}
.el-loading-spinner .path {
  stroke: #6a4c41 !important;
}
</style>
