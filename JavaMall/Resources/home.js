function App(){
	this.showGoods=function(goodsid){
		location.href='app://showgoods/' + goodsid;
	}
	this.changeTab=function(index){
		location.href='app://changetab/' + index;
	}
	this.myorder=function(){
		location.href='app://myorder';
	}
    this.showList=function(catid){
        location.href='app://showlist/' + catid;
    }
    this.showBrand=function(brandid){
        location.href='app://showbrand/' + brandid;
    }
    this.showSeckill=function(goodsid, actid){
        location.href='app://showseckill/' + goodsid + "/" + actid;
    }
    this.showSeckillList=function(){
        location.href='app://showseckilllist';
    }
    this.showGroupbuy=function(goodsid, groupbuyid){
        location.href='app://showgroupbuy/' + goodsid + "/" + groupbuyid;
    }
}
var app = new App();