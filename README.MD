# peg-git-diff-parser

使用 [peggy](https://peggyjs.org/documentation.html) 生成的 `git diff` 命令返回数据的解析器

> Peggy is a simple parser generator for JavaScript that produces fast parsers with excellent error reporting. You can use it to process complex data or computer languages and build transformers, interpreters, compilers and other tools easily.

配合 `simple-git` 之类，解析命令行中 `git diff` 命令返回的文本数据格式（只有修改模式）。

## 使用

`src` 下的 `gitDiffParser.peggy` 是 `peggy` 的规则逻辑，需要安装 `peggy` 才能使用解析。

`dist` 下的 `gitDiffParser.js` 是生成好的解析脚本，可以直接引入到项目中而无需安装 `peggy`

```js
const GitDiffParser = require("./gitDiffParser");
```

获取所需处理的文本，并导入到组件中  
解析器的第二个参数位设置参数 `REMOVE_INDENT`，用于控制是否去除解析后的文本的缩进。

```js
const fileName = "diff_data.txt";
const TEST_DATA = fs.readFileSync(
  path.resolve(__dirname, `../test/${fileName}`)
);

const result = GitDiffParser.parse(TEST_DATA.toString(), {
  REMOVE_INDENT: false, // 参数，是否去除解析文本中的缩进空格
});
```

预期格式：

```
diff --git a/package.json b/package.json
index cb2f4bc..35455a2 100644
--- a/package.json
+++ b/package.json
@@ -1,13 +1,14 @@
 {
   "name": "peg-git-diff-parser",
-  "version": "0.0.0",
+  "version": "1.0.0",
   "description": "git diff 文本解析器",
-  "main": "index.js",
+  "main": "src/index.js",
   "scripts": {
     "build": "peggy -o dist/gitDiffParser.js src/gitDiffParser.peggy",
     "test": "node src/index.js"
   },
   "author": "LnnCoCo",
+  "new": "new",
   "license": "ISC",
   "dependencies": {
     "peggy": "^1.2.0"
```

解析格式：

```js
{
  type: 'changed',
  filePath: { beforePath: '/package.json', afterPath: '/package.json' },
  hash: { beforeHash: 'cb2f4bc', afterHash: '35455a2' },
  mode: '100',
  permissions: '644',
  change: [
    {
      chunkHeader: '@@ -1,13 +1,14 @@',
      chunkBeforeLine: '1,13',
      chunkAfterLine: '1,14',
      content: [
        { type: '-', text: '  "version": "0.0.0",' },
        { type: '+', text: '  "version": "1.0.0",' },
        { type: '-', text: '  "main": "index.js",' },
        { type: '+', text: '  "main": "src/index.js",' },
        { type: '+', text: '  "new": "new",' }
      ]
    }
  ]
}
```

返回数据的 TS 定义：

```ts
interface GitDiffParserResult {
  type: "changed";
  filePath: { beforePath: string; afterPath: string };
  hash: { beforeHash: string; afterHash: string };
  mode: string;
  permissions: string;
  change: {
    chunkHeader: string;
    chunkBeforeLine: string;
    chunkAfterLine: string;
    content: {
      type: "+" | "-";
      text: string;
    }[];
  }[];
}
```
