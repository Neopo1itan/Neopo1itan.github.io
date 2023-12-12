---
title: 用React Hooks搭建一个电影搜索App
categories:
  - 前端开发
tags:
  - React
  - Web
abbrlink: 13078
date: 2023-07-12 15:55:35
---
这个 App 实现的效果是通过**OMDB API**来搜索电影并将结果展现给用户。搭建这个 App 的过程能帮助我们很好的学习**React Hooks**的用法，练习实际项目能帮助更快上手。

### App 完成后的效果预览

[![OzZvvc.md.png](https://i.imgtg.com/2023/07/13/OzZvvc.md.png)](https://imgtg.com/image/OzZvvc)

<!-- more -->
### 项目用到的工具

- Node
- VsCode
- OMDB 的 API key ([这里获得](http://www.omdbapi.com/apikey.aspx))

准备好上述工具后，我们需要用 react 的脚手架工具来帮助我们搭建一个全新的 React 应用程序，安装**create-react-app**脚手架：

```bash
npm i -g create-react-app
//或者用cnpm yarn都可以
```

然后通过脚手架新建项目:

```bash
create-react-app movie-search-app
```

完成之后用 VsCode 打开该目录，目录结构如下图所示：
[![structure](https://i.imgtg.com/2023/07/12/Ozh9w6.md.png)](https://imgtg.com/image/Ozh9w6)

### 构成该 App 的 4 个组件

- **App.js** —— 它是其它 3 个组件的父组件，将包含处理 API 请求的函数以及组件初始化时调用的 API
- **Header.js** —— 接受参数并展示 App 的标题
- **Movie.js** —— 渲染每个电影，电影对象将通过参数传递给它
- **Search.js** —— 包含一个带有输入和搜索按钮的表单，处理输入和重置的函数以及一个作为参数传递给它的搜索函数

### 开始着手构建我们的 APP

在`src`目录下新建一个文件夹命名为`components`(之后所有组件都将保存在这个地方)，然后把`App.js`组件移动到该目录下。新建一个`Header.js`组件用于展示程序的标题，并加入如下代码：

```js
// Header.js
import React from "react";

const Header = (props) => {
  return (
    <header className="App-header">
      <h2>{props.text}</h2>
    </header>
  );
};

export default Header;
```

更新`src`目录下`index.js`中的导入

```js
//index.js
import App from './components/App';
```

并且更新`App.css`中的样式代码(供参考)：

```css
.App {
  text-align: center;
}

.App-header {
  background-color: #282c34;
  height: 70px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
  padding: 20px;
  cursor: pointer;
}

.spinner {
  height: 80px;
  margin: auto;
}

.App-intro {
  font-size: large;
}

/* new css for movie component */
* {
  box-sizing: border-box;
}

.movies {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
}

.App-header h2 {
  margin: 0;
}

.add-movies {
  text-align: center;
}

.add-movies button {
  font-size: 16px;
  padding: 8px;
  margin: 0 10px 30px 10px;
}

.movie {
  padding: 5px 25px 10px 25px;
  max-width: 25%;
}

.errorMessage {
  margin: auto;
  font-weight: bold;
  color: rgb(161, 15, 15);
}

.search {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  margin-top: 10px;
}

input[type="submit"] {
  padding: 5px;
  background-color: transparent;
  color: black;
  border: 1px solid black;
  width: 80px;
  margin-left: 5px;
  cursor: pointer;
}

input[type="submit"]:hover {
  background-color: #282c34;
  color: antiquewhite;
}

.search > input[type="text"]{
  width: 40%;
  min-width: 170px;
}

@media screen and (min-width: 694px) and (max-width: 915px) {
  .movie {
    max-width: 33%;
  }
}

@media screen and (min-width: 652px) and (max-width: 693px) {
  .movie {
    max-width: 50%;
  }
}

@media screen and (max-width: 651px) {
  .movie {
    max-width: 100%;
    margin: auto;
  }
}
```

<font color="gray" size=2>随时可以用<font color=#C4244D size=2>npm start</font>启动项目来查看效果</font>

下一步创建`Movie.js`组件，代码如下

```js
//Movie.js
import React from "react";

const DEFAULT_PLACEHOLDER_IMAGE = 
"https://m.media-amazon.com/images/M/MV5BMTczNTI2ODUwOF5BMl5BanBnXkFtZTcwMTU0NTIzMw@@._V1_SX300.jpg";

const Movie = ({movie}) => {
    //不存在则展示默认图片
    const poster = movie.Poster === "N/A"? DEFAULT_PLACEHOLDER_IMAGE : movie.Poster;
    return(
        <div className="movie">
            <h2>{movie.Title}</h2>//展示电影标题
            <div>
                <img src={poster} alt={`The movie titled:${movie.Title}`} width="200" />
            </div>
            <p>({movie.Year})</p>//展示电影年份
        </div>
    )
}

export default Movie;
```

接下来开始创建`Search`组件。这是最关键的一部分，因为使用Hooks之前的React为了处理内部状态需要创建一个类组件...不过现在利用Hooks可以在函数组件内部处理自己的状态。在`components`文件夹下新建`Search.js`文件并加入如下代码：

```js
//Search.js
import React, { useState } from "react"

const Search = (props) => {
    const [searchValue, setSearchValue] = useState('');
    const handleSearchInputChanges = (e) => {
        setSearchValue(e.target.value);//修改搜索值
    }
    const resetInputField = () => {
        setSearchValue('');//重置搜索
    }
    const callSearchFunction = (e) => {
        e.preventDefault();//阻止默认操作
        props.search(searchValue);//调用搜索
        resetInputField();//调用重置函数
    }

    return(
        <form className="search">
            <input type="text" value={searchValue} onChange={handleSearchInputChanges}/>
            <input type="submit" value="SEARCH" onClick={callSearchFunction} />
        </form>
    )
}

export default Search;
```

### Hooks API - useState介绍
>
>在`Search.js`组件中使用了一个**hooks API**，即**useState**。顾名思义它允许我们向函数组件添加React状态。**useState**钩子接收一个初始状态参数，并返回一个数组包含当前的状态（*this.state*）和一个更新它的函数（*this.setState*）。
>在我们的示例中，我们将当前状态作为搜索输入值传递。在输入框触发onChange事件时，将调用*handleSearchInputChanges*函数用于更新输入的搜索值。*resetInputField*方法用于清空当前搜索框的值。([更多useState内容](https://legacy.reactjs.org/docs/hooks-state.html))

接下来让我们更新`App.js`中的代码

```js
//App.js
import React, { useEffect, useState } from "react"
import './App.css';
import Header from './Header';
import Movie from './Movie';
import Search from './Search';

const MOVIE_API_URL = "https://www.omdbapi.com/?s=man&apikey=4a3b711b"; // 用自己的替换

const App = () => {
  const [loading, setLoading] = useState(true);//加载状态
  const [movies, setMovies] = useState([]);//电影列表
  const [errorMessage,setErrorMessage] = useState(null);//错误信息

  useEffect(()=>{
    fetch(MOVIE_API_URL).then(response => response.json()).then(jsonResponse => {
      setMovies(jsonResponse.Search);
      setLoading(false);
    });
  },[]);

  const search = searchValue => {//搜索方法
    setLoading(true);
    setErrorMessage(null)

    fetch(`https://www.omdbapi.com/?s=${searchValue}&apikey=4a3b711b`)
        .then(response => response.json())
        .then(jsonResponse => {
            if(jsonResponse.Response === "True"){
                setMovies(jsonResponse.Search);
                setLoading(false);
            }else{
                setErrorMessage(jsonResponse.Error);
                setLoading(false);
            }
        });
  };

  return(
    <div className='App'>
      <Header text="MovieSearchApp"></Header>
      <Search search={search}></Search>
      <p className='App-intro'>分享一些喜欢的电影</p>
      <div className='movies'>
        { loading&&!errorMessage?(
        <span>loading...</span>
        ):errorMessage?(
        <div className='errorMessage'>{errorMessage}</div>
        ):(
          movies.map((movie,index) => (
            <Movie key={`${index}-${movie.Title}`} movie={movie}/>
          ))
        )}
      </div>
    </div>
  );
};
export default App;
```

在上述代码中，我们用到了3个**useState**函数，第一个函数用于处理当前加载状态；第二个函数用于处理从服务器获取的电影数组；第三个函数用于处理API请求时可能返回的错误信息。

然后我们用到了第二种hooks API：**useEffect**
这个钩子基本上能让你在函数组件中执行副作用，副作用指的是例如数据获取，订阅和手动操作DOM这类事情。这个钩子最棒的一部分来自官方文档的介绍：
>如果你熟悉React的类的生命周期方法，你可以将useEffect看作componentDidMout，componentDidUpdate和componentWillUnmount的结合。

这是因为**useEffect**会在第一次渲染（componentDidMount）之后和每次更新（componentDidUpdate）之后进行调用。

你可能想知道如果它在每次更新之后都进行调用，那么它和componentDidMount有何相似的地方？那是因为这个函数接受两个参数，一个是你想要运行的函数另一个是数组。在该数组中我们只需要传入一个值去告诉React如果该值没有修改则跳过应用的函数效果。

根据文档，这和我们在componentDidUpdate中添加一个if判断语句类似：

```js
//for class components
componentDidUpdate(prevProps, prevState) {
    if(prevState.count !== this.state.count){
        document.title = `You clicked ${this.state.count} times`;
    }
}

//for hooks
useEffect(() => {
    document.title = `You clicked ${count} times`;
},[count]);// 只有count改变了才会再执行
```

在我们的代码中初始化时并没有要改变的值，所以可以传入一个空数组来告诉React这个方法需要调用一次。

如你所见，我们有三个存在一定联系的**useState**函数，所以它们应该可以用某种方式组合起来。因此React为我们提供了另一个hook——**useReducer**。利用这个钩子我们的代码变成如下所示：

```js
const initialState = {
  loading:true,
  movies:[],
  errorMessage:null
}
const reducer = (state,action) => {
  switch(action.type){
    case "SEARCH_MOVIES_REQUEST":
      return{
        ...state,
        loading:true,
        errorMessage:null
      };
    case "SEARCH_MOVIES_SUCCESS":
      return{
        ...state,
        loading:false,
        movies:action.payload
      };
    case "SEARCH_MOVIES_FAILURE":
      return{
        ...state,
        loading:false,
        movies:action.error
      };
    default:
      return state;
  }
};
const App = () => {
  const [state,dispatch] = useReducer(reducer,initialState);
  useEffect(() => {
    fetch(MOVIE_API_URL)
      .then(response => response.json())
      .then(jsonResponse => {
        dispatch({
          type:"SEARCH_MOVIES_SUCCESS",
          payload:jsonResponse.Search
        });
      });
  },[]);

  const search = searchValue => {//搜索方法
    dispatch({
      type:"SEARCH_MOVIES_REQUEST"
    });
    fetch(`https://www.omdbapi.com/?s=${searchValue}&apikey=4a3b711b`)
      .then(response => response.json())
      .then(jsonResponse => {
        if(jsonResponse.Response === "True"){
          dispatch({
            type:"SEARCH_MOVIES_SUCCESS",
            payload:jsonResponse.Search
          });
        }else{
          dispatch({
            type:"SEARCH_MOVIES_FAILURE",
            error:jsonResponse.Error
          });
        }
      });
  };
const { movies, errorMessage, loading} = state;
  return(
    <div className='App'>
      <Header text="MovieSearchApp"></Header>
      <Search search={search}></Search>
      <p className='App-intro'>分享一些喜欢的电影</p>
      <div className='movies'>
        { loading&&!errorMessage?(
        <span>loading...</span>
        ):errorMessage?(
        <div className='errorMessage'>{errorMessage}</div>
        ):(
          movies.map((movie,index) => (
            <Movie key={`${index}-${movie.Title}`} movie={movie}/>
          ))
        )}
      </div>
    </div>
  );
};
```

**useReducer**钩子接受3个参数，不过我们只使用了其中2个。一个典型的用力如下：

```js
const [state, dispatch] = useReducer(reducer,initialState);
```

在我们的代码中，reducer接收我们定义的initialState对象和一系列操作，基于操作的类型返回给我们新的状态对象。例如我们的操作类型是"**SEARCH_MOVIES_REQUEST**"，状态将更新为"loading=true,errorMessage=null"。

另一件需要注意的事情是，在**useEffect**中，我们将从服务器获取的电影数组作为payload来执行dispatch操作，在`search`方法中我们实际上有3个不同的操作。

- SEARCH_MOVIES_REQUEST：更新状态对象，loading=true，errorMessage=false。
- SEARCH_MOVIES_SUCCESS：如果请求成功，那么更新状态，loading=false，movies=a_ction.payload。payload是从OMDB获取到的电影搜索结果。
- SEARCH_MOVIES_FAILURE：请求失败的话，loading=false，errorMessage=action.error。error也是服务器返回的错误消息。

### 总结

至此我们整个项目做完了，用到了**useState**、**useReducer**、**useEffect**三个hooks。对React hooks的用法有了一个基本的了解，更多详细的内容推荐去官网阅读。

> 原文链接:
> <https://www.freecodecamp.org/news/how-to-build-a-movie-search-app-using-react-hooks-24eb72ddfaf7/>
