class CustomLinks extends React.Component{
  render(){
    return <span dangerouslySetInnerHTML={{__html: this.props.item.custom_links}}/>
  }
}

class Item extends React.Component {
  mtime(){ return moment(new Date(this.props.item.mtime)).format('YYYY/MM/DD hh:mm:ss'); }

  render(){
    var item = this.props.item;
    return <span className='main_span'>
      <NewFlag 
        item={this.props.item}
        state={this.props.state}
      />
      <a href={item.url} className='main_link'>{item.name}</a>&nbsp;

      <Watch 
        item={this.props.item}
        state={this.props.state}
      />
      <span className='mtime'>{this.mtime()}</span>&nbsp;
      <span className='size'>{size_pretty(item.size)}</span>&nbsp;
      <CustomLinks item={this.props.item} />
    </span>
  }
}

class Pager extends React.Component {
  constructor(props){
    super(props);
    this.page = 1;
    var page = this.props.state.controller.params().page;
    if(page){ this.page = parseInt(page)}
    this.bind();
  }

  bind(){
    $(window).on("scroll",()=>{
      var scrollHeight = $(document).height();
      var scrollPosition = $(window).height() + $(window).scrollTop();
      if ((scrollHeight - scrollPosition) / scrollHeight === 0) {
        if(this.props.state.controller.can_sort_and_paging()|| location.pathname == '/latest'){
          this.click();
        }
      }
    });
  }
  click(){
    this.page ++;
    if(location.pathname == '/latest'){
      var url = this.props.state.controller.route().api_url += `?page=${this.page}`;
    } else {
      var url = this.props.state.controller.route().api_url += `&page=${this.page}`;
    }
    $.get(url).done((data)=>{
      this.props.state.items = this.props.state.items.concat(data);
      this.props.state.update_state();
      if(location.pathname == '/latest'){
        var new_url = `/latest?page=${this.page}`;
      } else {
        var new_url = `/?query=${this.props.state.controller.query()}&page=${this.page}`;
      }
      history.pushState('', '', new_url);
    });
  }

  render(){ return <a href='javascript:void(0)' onClick={()=> this.click()}>Next</a> }
}


class List extends React.Component {
  can_sort(){ return this.props.state.controller.can_sort_and_paging()} 
  render(){

    var items = $.map(this.props.state.items, (item)=>{
      return <Item
        key={item.key}
        state={this.props.state}
        item={item}
      />
    });

    return <div>
      {this.can_sort() ?  <Sort state={this.props.state} /> : null }
      <p>{items}</p>
      <p>{this.can_sort() || location.pathname == '/latest' ?  <Pager state={this.props.state} /> : null }</p>
    </div>
  }
}

window.List = List;
