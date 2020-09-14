---
layout: ursa
lang: ru-RU
title: U.R.S.A. Генератор персонажа
---

<div id="nav-placeholder"></div>
<script>
$(function(){
  $("#nav-placeholder").load("/ursa_doc/navbar.html");
});
</script>

<div id="myReactApp"></div>

<script type="text/babel">
  class Greeter extends React.Component { 
    render() { 
      return <h1>{this.props.greeting}</h1>
    } 
  } 

  ReactDOM.render(<Greeter greeting="Hello World!" />, document.getElementById('myReactApp'));
</script>
