title: git常用小技巧
date: 2018-3-04 11:00:00
tags:
    - git
---

### git常用小技巧

*撤销commit*

```js
git reset --soft HEAD^
```

*撤销add*

```js
git reset --mixed
```

*删除中间某几个commit*
```js
A - B - C - D - E  // 字母代表commitId，比如我想撤销，B和D
// 首先
git rebase -i A

// 然后出现编辑文件
// 删除调
pick B ...
pick D ...
// 保存
```

*让你的git log好看点*

```js
git config --global alias.glog "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
```