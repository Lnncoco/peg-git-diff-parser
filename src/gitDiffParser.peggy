{{
  /**
   * 将行信息转换为可读文本格式
   * [ [ '1', '1' ], ',', [ '1', '4' ] ] ==>> 11,14
   **/
  const formatLine = (array) => {
    if(!array || !array.length) return array;
    return array.reduce((text, item) => {
      if(!Array.isArray(item)) {
        text += ','
        return text;
      }
      text += item.join("")
      return text;
    }, "")
  }
}}

start
  = diff

/**
 * 解析 git diff 文本
 **/
diff
  = header:header // diff头信息行
    fileInfo:fileInfo // diff文件信息行
    beforeChangeFileName:changeFileName // diff修改前的文件名
    afterChangeFileName:changeFileName // diff修改后的文件名
    changeChunk:changeChunk // 变动信息块
    {
      const change = [];
      let chunk = {}
      if(Array.isArray(changeChunk)) changeChunk.forEach(item => {
        if(item.changeHeader){
          if(Object.keys(chunk).length) change.push(chunk);
          chunk = {
            chunkHeader: item.changeHeader,
            chunkBeforeLine: item.beforeChangeLine.line,
            chunkAfterLine: item.afterChangeLine.line,
          }
        } else {
          const itemCopy = {...item}
          if(options.REMOVE_INDENT && itemCopy.text) itemCopy.text = itemCopy.text.trim()
          if(chunk.content){
            chunk.content.push(itemCopy);
          }
          else chunk.content = [itemCopy];
        }
      })
      if(Object.keys(chunk).length) change.push(chunk);
      return {
        type: 'changed',
        filePath: header,
        hash: fileInfo.hash,
        mode: fileInfo.mode,
        permissions: fileInfo.permissions,
        change
      }
    }


/** 
 * 首行
 **/
header
  = "diff"i _ "--git"i _ 'a'beforePath:filePath _ 'b'afterPath:filePath LINE_END
  {
    return {
      beforePath,
      afterPath
    }
  }


/** 
 * 文件信息
 **/
fileInfo
  = zone:zone _ hash:hash _ mode:mode permissions:permissions LINE_END
  {
    return {
      zone,
      hash,
      mode,
      permissions
    }
  }

// 区域
zone = hit:[A-Za-z]+ { return hit.join("") }
// hash
hash
  = 
    beforeHash:[A-Za-z0-9]+
    ..
    afterHash:[A-Za-z0-9]+
    {
      return {
        beforeHash: beforeHash.join(""),
        afterHash: afterHash.join(""),
      }
    }
// 文件与权限信息
mode = hit:([0-9][0-9][0-9]) { return hit.join("") }
permissions = hit:([0-9][0-9][0-9]) { return hit.join("") }

/** 
 * 文件名称变化
 **/
changeFileName
  = type:[-|\+]+ _ filePathChange:filePath LINE_END
  {
    return {
      type: type.join(""),
      filePathChange,
    }
  }


/** 
 * 变动块
 **/
changeChunk
  = hit:(
      line:changeHeader
      / beforeContent:changeBeforeContent
      / afterContent:changeAfterContent
      / changeContext
    )*
    {
      return hit.filter(item => item)
    }

// 变动头
// -：变化前；+：变化后
// 第N行开始,一共N行  1,6 第一行开始,一共6行（变化的-+两行算一行）
changeHeader
  = "@@" _ beforeChangeLine:changeLineInfo _ afterChangeLine:changeLineInfo _ "@@" LINE_END
  {
    return {
      changeHeader: `@@ ${beforeChangeLine.text} ${afterChangeLine.text} @@`,
      beforeChangeLine,
      afterChangeLine
    }
  }

// 变动行信息  第N行开始,一共N行  1,6 第一行开始,一共6行（变化的-+两行算一行）
changeLineInfo
  = type:([-|+]) line:([0-9]+","[0-9]+)
  {
    const lineFormatText = formatLine(line);
    return {
      text: `${type}${lineFormatText}`,
      type,
      line: lineFormatText
    }
  }

// 预览信息上下最多取三行
// 空格开头：无变化内容；-开头：原始内容；+开头：修改后内容
changeContext = (SPACE / .) {
  return null
}
changeBeforeContent = LINE_END "-" hit:[^\r\n]+ {
  return {
    type: "-",
    text: hit.join("")
  }
}
changeAfterContent = LINE_END "+" hit:[^\r\n]+ {
  return {
    type: "+",
    text: hit.join("")
  }
}


/**
 * 公共定义
 */

// 路径文件名
filePath = hit:[A-Za-z0-9\\\/\._\-@$()*&^+!]+ { return hit.join("") }

// 换行
LINE_END = "\r\n" / "\n"

// 空白符
__ = SPACE* { return "" }
_ = SPACE+ { return "" }
SPACE = " " / "\t"