const fs = require("fs");
const path = require("path");

const PEG = require("peggy");

// 读取规则
const RULE_DIFF = fs.readFileSync(
  path.resolve(__dirname, "./gitDiffParser.peggy")
);
const parser = PEG.generate(RULE_DIFF.toString(), {
  // format: "commonjs",
  // optimize: "speed",
  // trace: true,
});

// 读取测试数据
const fileName = "diff_data.txt";
const TEST_DATA = fs.readFileSync(
  path.resolve(__dirname, `../test/${fileName}`)
);

// 进行解析
try {
  const result = parser.parse(TEST_DATA.toString(), {
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
