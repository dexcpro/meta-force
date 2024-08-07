<template>
  <router-view />
</template>
<style>
html,
body {
  box-sizing: border-box;
  font-size: calc(100vw / 3.75);
  margin: 0; /* 移除外边距 */
  padding: 0; /* 移除内边距 */
  overflow-x: hidden;
  /* overflow: hidden; */
  min-height: 100%;
  height: auto;
}
body {
  position: relative;
  font-size: 0.16rem;
  margin: 0; /* 移除外边距 */
  padding: 0; /* 移除内边距 */
  border: none; /* 移除边框 */
  /* background: rgb(48, 49, 51); */
  background: #303133;
  /* touch-action: none !important; */
  user-select: none;
}
* {
  box-sizing: border-box;
  touch-action: none !important;
}
:root {
  --wui-color-accent-100: #ffffff31 !important;
  --wui-color-accent-090: none !important;
  --wui-color-fg-200: #ffffff !important;
  --w3m-accent: none !important;
  --foot-back: #252c41;
  --primary-color: #13c07e !important;
  --hcan1-color: #13c07e !important;
  --hcan2-color: #00e766 !important;
  --bac-background: #f8f8f8 !important;
  --border-color: #f2f6fc !important;
  --el-color-primary: #13c07e !important;
  --el-color-primary-dark-2: #108560 !important;
  --el-color-primary-light-3: #4ad991 !important;
  --el-color-primary-light-5: #7edfbf !important;
  --el-color-primary-light-7: #a4e6d3 !important;
  --el-color-primary-light-8: #b7edda !important;
  --el-color-primary-light-9: #cbf5e1 !important;
}
a {
  text-decoration: none; /* 去除下划线 */
  color: inherit; /* 继承父元素的颜色 */
  /* 如果需要，可以添加其他样式来去除背景、边框等 */
}
.pge {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

@media (min-width: 625px) {
  body {
    font-size: 26.2125px;
  }
}
</style>
