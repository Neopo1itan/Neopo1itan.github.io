/*
 * @Descripttion: 
 * @version: 
 * @Author: 雷宇琦
 * @Date: 2023-07-13 10:47:27
 * @LastEditors: 雷宇琦
 * @LastEditTime: 2023-07-13 10:47:53
 */
var alltags = document.getElementsByClassName("tag-cloud-tags");
var tags = alltags[0].getElementsByTagName("a");
for (var i = tags.length - 1; i >= 0; i--) {
  var r = Math.floor(Math.random() * 75 + 130);
  var g = Math.floor(Math.random() * 75 + 100);
  var b = Math.floor(Math.random() * 75 + 80);
  tags[i].style.background = "rgb(" + r + "," + g + "," + b + ")";
}
