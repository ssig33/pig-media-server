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
      <span className='size'>{size_pretty(item.size)}</span>
    </span>
  }
}


class List extends React.Component {
  render(){
    var items = $.map(this.props.state.items, (item)=>{
      return <Item
        key={item.key}
        state={this.props.state}
        item={item}
      />
    });

    return <div>
      <p>{items}</p>
      <p>
        Pager
      </p>
    </div>
  }
}

window.List = List;
