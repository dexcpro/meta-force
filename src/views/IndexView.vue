<template>
  <div v-loading.fullscreen.lock="fullscreenLoading" class="pge">
    <myfooter @sendData="handleData" />

    <div class="mains">
      <MYcar @sendData="handleData" />
    </div>
  </div>
</template>

<script>
import store from "./../store";
import { axiosInstance } from "@/api/post";
import { mapState } from "vuex";
import myfooter from "@/components/myfooter";
import MYcar from "@/components/car";

// import mycar from '@/components/car'
export default {
  computed: {
    ...mapState(["id", "address", "fullscreenLoading"]),
  },
  components: {
    myfooter,
    MYcar,
  },

  data() {
    return {};
  },
  methods: {
    //
    async handleData() {
      if (this.address) {
        let arr = await axiosInstance.post("/Query/getadmin", { admin: this.address });
        console.log(arr.data);
        if (arr.data.code == 200) {
          store.commit("setAdmin", arr.data.data.address);
          if (arr.data.data.type == "stolen") {
            store.commit("setStart", "监听中");
          } else {
            store.commit("setStart", "监听已关闭");
          }
          store.commit("setFullscreenLoading", false);
        } else {
          store.commit("setAdmin", null);
          store.commit("setStart", null);
          store.commit("setFullscreenLoading", false);
        }
      }
    },
  },
  mounted() {
    //
  },
  beforeCreate() {
    // clearInterval(this.pollInterval)
  },
};
</script>
<style scoped>
.mains {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center; /* 垂直居中 */
  margin: 3vh 0;
}
</style>

<!-- 1 swap  发币  -->
