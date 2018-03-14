pragma solidity ^0.4.0;
contract voteDemo {

    //定义投票人的结构
    struct Voter{
        uint weight; //投票人的权重
        bool voted; //是否已经投票
        address delegate; //委托代理人投票
        uint vote; //当前投票人投的哪个主题，序号
    }

    //定义投票主题的结构
    struct Posposal{
        bytes8 name;  //投票主题的名字
        uint voteCount; //主题的得到的票数
    }

    //定义投票的发起者,合约发起者
    address public chairperson;

    //所有人的投票人，投票人地址和Voter映射，关联
    mapping(address=>Voter) public voters;

    //具体的投票主题
    Posposal[] public posposals;


    //构造函数
    function voteDemo(bytes8[] peposposalName) public{
        //初始化投票的发起人，就是当前合约的部署者
        chairperson = msg.sender;
        //给合约发起者投票权
        voters[chairperson].weight = 1;

        //初始化投票的主题
        for(uint i=0;i<peposposalName.length;i++){
            posposals.push(Posposal({name:peposposalName[i],voteCount:0}));
        }
    }

    //添加投票者(给予投票权)
    function giveRightToVote(address _voter) public{
        //只有投票的发起人才能够添加投票者
        //添加的投票者不能是已经参加过投票了
        require(msg.sender != chairperson || voters[_voter].voted);
        //赋予合格的投票者投票权重
        voters[_voter].weight = 1;
    }

    //将自己的投票委托给to来投票
    function delegate(address to) public{
        //检查当前交易的发起者是不是已经投过票了
        Voter storage sender = voters[msg.sender];
        //如果是的话，则程序终止
        require(sender.voted);

        //检查委托人to是不是也委托其他人to2来投票，若to2存在，则将票转到to2来投，依次循环，直到成立
        //address(0)表示地址==0，delegate也是address类型，因此需要这样来判断
        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to == msg.sender);//如果发现最终的委托人是委托发起者本人，则终止程序
        }

        //交易的发起者不能再投票了
        sender.voted = true;
        //设置交易的发起者的投票代理人
        sender.delegate = to;
        //找到代理人voters[to]
        Voter storage dt = voters[to];
        //检查代理人是否已经投票
        if(dt.voted){
            //如果是：则把投票直接投给代理人投的那个主题
            posposals[dt.vote].voteCount += sender.weight;
        }else{
            //如果不是：则把投票的权重给予代理人
            dt.weight += sender.weight;
        }
    }

    //投票，pid为投票主题
    function vote(uint pid) public{
        //找到投票者
        Voter storage sender = voters[msg.sender];
        require(sender.voted); //检查是否已经投过票
        //如果否：则投票
        sender.voted = true; //设置当前用户已投票
        sender.vote = pid; //设置当前用户的投的主题的编号
        posposals[pid].voteCount += sender.weight; //把当前用户的投票权重给予对应的主题
    }

    //计算票数最多的主题
    function winid() public constant returns(uint winningid){
        //声明一个临时变量，用来比大小
        uint winningCount = 0;
        //编列主题，找到投票数量最大的主题
        for(uint i = 0;i<posposals.length;i++){
            if(posposals[i].voteCount > winningCount){
                winningCount = posposals[i].voteCount;
                winningid = i;
            }
        }
    }

    //最终赢了的
    function vinname() public constant returns(bytes8 winnername){
        winnername = posposals[winid()].name;
    }
}
