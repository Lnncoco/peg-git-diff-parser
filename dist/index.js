const fs = require("fs");
const path = require("path");

// 生成后的解析器
const GitDiffParser = require("./gitDiffParser");

// 读取测试数据
const fileName = "diff_data.txt";
const TEST_DATA = fs.readFileSync(
  path.resolve(__dirname, `../test/${fileName}`)
);

// 进行解析
try {
  const result = GitDiffParser.parse(TEST_DATA.toString(), {
    // startRule: "start",
    // tracer: true,
    REMOVE_INDENT: false,
  });
  console.log("解析结果：");
  console.log(result);
  // console.log(JSON.stringify(result));
} catch (e) {
  console.error("解析错误：");
  console.error(e);
}
