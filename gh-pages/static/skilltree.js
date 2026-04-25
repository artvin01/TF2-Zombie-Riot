// GLOBALS ===================================================
const ctx = document.getElementById("canvas").getContext("2d");
const pagetitle = document.getElementById("title");

let last_mousepos = [0,0];
let campos = [0,0];
let reset_cam = true;
let zoom = 1;

let skilltree_data = [];
let pointdata = {};
let total_points = 0;

// MOUSE FUNCTIONS ===================================================
var mousedown = false;
let mouseclick = [false,false,false];
let mousepos = [0,0];

function setPrimaryButtonState(e) {
  if (event.type==="mousedown") {
    mouseclick[e.button] = true;
  };
  if (ctx.canvas.style.cursor==="grab" | ctx.canvas.style.cursor==="grabbing") {
    var flags = e.buttons !== undefined ? e.buttons : e.which;
    mousedown = (flags & 1) === 1;
  }
};

ctx.canvas.addEventListener("mousedown", setPrimaryButtonState);
document.addEventListener('mousemove', function(event) {
    bounds = ctx.canvas.getBoundingClientRect();
    mousepos = [event.clientX-bounds.left, event.clientY-bounds.top];
    if ((event.clientX < bounds.left) || (event.clientY < bounds.top) || (event.clientX > bounds.right) || (event.clientY > bounds.bottom)) {
      mousedown = false;
    }
});
ctx.canvas.oncontextmenu = function() {
  return false;
}
ctx.canvas.addEventListener("mouseup", setPrimaryButtonState);


ctx.canvas.addEventListener("wheel", function (e) {
    let prevzoom = zoom;  
    zoom -= e.deltaY/300;
    if (zoom<.4) {zoom=.4};
    if (zoom>5) {zoom=5};
    let diff = zoom-prevzoom;

    let zoompos = [mousepos[0]-campos[0],mousepos[1]-campos[1]]
    
    // https://stackoverflow.com/questions/2916081/zoom-in-on-a-point-using-scale-and-translate
    // kinda janky
    campos[0] += -(zoompos[0] * diff)/zoom;
    campos[1] += -(zoompos[1] * diff)/zoom;


    return false;
    
}, true);


// DRAW ===================================================
function draw() {
  ctx.canvas.width = pagetitle.offsetWidth;
  ctx.canvas.height = 1000;
  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  if (reset_cam) {
    campos = [ctx.canvas.width/2,ctx.canvas.height/2];
    zoom = 1;
    reset_cam=false;
  }

  ctx.save();
  ctx.fillStyle=`rgba(255,0,255,25%)`;
  ctx.strokeStyle="#b4b8ab33";
  ctx.lineWidth = 2;
  ctx.setLineDash([5]);
  ctx.beginPath();
  let xscroll = (campos[0]%(ctx.getLineDash()[0]*2));
  let yscroll = (campos[1]%(ctx.getLineDash()[0]*2));
  ctx.moveTo(xscroll, campos[1]); ctx.lineTo(ctx.canvas.width+xscroll, campos[1]);
  ctx.moveTo(campos[0], yscroll); ctx.lineTo(campos[0], ctx.canvas.height+yscroll);
  ctx.stroke();
  ctx.restore();

  ctx.font = `${16*zoom}px Oswald`;
  ctx.canvas.style.cursor = "grab";
  parse_main(skilltree_data[0],campos[0],campos[1]-150*zoom, 0);
  prerun=render(prerun);
  run=render(run);
  postrun=render(postrun);

  if (mousedown) {
      campos[0] += (mousepos[0]-last_mousepos[0]);
      campos[1] += (mousepos[1]-last_mousepos[1]);
      ctx.canvas.style.cursor = "grabbing";
  }

  mouseclick=[false,false,false];
  last_mousepos=mousepos;
  window.requestAnimationFrame(draw);
}

// UI FUNCS ===================================================
prerun = []
run = []
postrun = []
function parse_main(data,px,py,parentpts) {
  let x = data["pos"][0]*200*zoom+campos[0];
  let y = data["pos"][1]*200*zoom+campos[1];
  let unlocked = parentpts >= data.minparent;

  let cost=1;
  if ("cost" in data) {cost=Math.max(Number(data.cost),1);}
  // Draw rect
  run.push({
    "type": "button",
    "disabled": !unlocked,
    "fillStyle": unlocked ? "#282828" : "#333333",
    "pos": [x,y],
    "size": [150*zoom,150*zoom],
    "args": [data,unlocked,cost],
    "onhover": {
      "func": function(data) {
        ctx.font = "16px Oswald";
        let text = ctx.measureText(data.desc);
        let w = text.width+50;
        postrun.push({
          "type": "rect",
          "fillStyle": "#b4b8ab",
          "size": [w,16+50],
          "pos": [mousepos[0]-(w/2), mousepos[1]+30]
        })
        postrun.push({
          "type": "text",
          "fillStyle": "#153243ff",
          "textAlign": "center",
          "text": data.desc,
          "pos": [mousepos[0], mousepos[1]+70],
          "noscale": true
        })
      },
      "args": [data]
    },
    "onclick": function(data,unlocked,cost) {
      if (unlocked) {
        if (!(data.path in pointdata)) {pointdata[data.path] = 0};
        let prev = pointdata[data.path];
        if (mouseclick[0]) {pointdata[data.path] += 1};
        if (mouseclick[2]) {pointdata[data.path] -= 1};
        if (pointdata[data.path] > data["max"]) {pointdata[data.path]=data["max"]};
        if (pointdata[data.path] < 0) {pointdata[data.path]=0};
        if (pointdata[data.path]-prev !== 0) {
          total_points += mouseclick[0] ? cost : -cost;
          document.getElementById("skillpoint_amt").innerHTML=total_points;
        }
      }
    }
  })
  
  // Draw text
  let point_amt=0;
  if (data.path in pointdata) {
    point_amt = Number(pointdata[data.path]);
  }

  // Reset points if not unlocked anymore
  if (!unlocked && point_amt>0) {
    total_points -= cost*point_amt;
    pointdata[data.path] = 0;
    document.getElementById("skillpoint_amt").innerHTML=total_points;
  };

  postrun.push({
    "type": "text",
    "fillStyle": unlocked ? "#ffffff" : "#ffffff22",
    "textAlign": "center",
    "text": data["name"],
    "pos": [x+75*zoom, y+50*zoom]
  })
  postrun.push({
    "type": "text",
    "fillStyle": unlocked ? "#ffffff" : "#ffffff22",
    "textAlign": "center",
    "text": `${point_amt}/${data["max"]}`,
    "pos": [x+75*zoom, y+75*zoom]
  })
  let ay = 75;
  if (data.minparent>1) {
    ay+=25;
    postrun.push({
      "type": "text",
      "fillStyle": unlocked ? "#ffffff" : "#ffffff22",
      "textAlign": "center",
      "text": `PARENT ${data.minparent}`,
      "pos": [x+75*zoom, y+ay*zoom]
    })
  }
  if (data.cost>1) {
    ay+=25;
    postrun.push({
      "type": "text",
      "fillStyle": unlocked ? "#ffffff" : "#ffffff22",
      "textAlign": "center",
      "text": `COST ${data.cost}`,
      "pos": [x+75*zoom, y+ay*zoom]
    })
  }

  // Draw line from parent to own
  prerun.push({
    "type": "line",
    "lineWidth": unlocked ? 5 : 2,
    "strokeStyle": "#cbc7c0",
    "from": [px+75*zoom, py+75*zoom],
    "to": [x+75*zoom,y+75*zoom]
  })

  // Repeat recursively
  data["paths"].forEach(function(val){
    parse_main(val,x,y,point_amt);
  })
}

function render(arr) {
  arr.forEach(function(element) {
    if (element.type === "text") {
      ctx.save()
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.textAlign=element.textAlign;
      if (element.noscale) {
        ctx.font = "16px Oswald";
      }
      ctx.fillText(element.text, ...element.pos);
      ctx.restore();
    } else if (element.type === "line") {
      ctx.save();
      ctx.beginPath();
      ctx.strokeStyle=element.strokeStyle; // Text color
      ctx.lineWidth=element.lineWidth; // Text color
      ctx.moveTo(...element.from);
      ctx.lineTo(...element.to);
      ctx.stroke();
      ctx.restore();
    } else if (element.type === "button") {
      ctx.save();
      ctx.beginPath();
      if (UiRect(ctx,...element.pos,...element.size,element.disabled,element.onhover)) {
        element.onclick(...element.args);
      }
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.fill();
      ctx.restore();
    } else if (element.type === "rect") {
      ctx.save();
      ctx.beginPath();
      ctx.roundRect(...element.pos,...element.size,5);
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.fill();
      ctx.restore();
    }
  })
  return [];
}

// UTIL ===================================================
function UiRect(ctx,x,y,w,h,disabled,onhover) {
  ctx.roundRect(x,y,w,h,5);
  if (mousepos[0]>=x && mousepos[0]<=x+w && mousepos[1]>=y && mousepos[1]<=y+h) {
    onhover.func(...onhover.args);
    if (!disabled) {
      ctx.canvas.style.cursor = "pointer";
      return mouseclick.some(function(el){return el});
    }
  }
  return false;
}

// INTERFACE ===================================================
function skilltree_resetcam() {
  reset_cam = true;
}

function skilltree_reset() {
  pointdata={};
  total_points=0;
  document.getElementById("skillpoint_amt").innerHTML=total_points;
}

// REQUEST ===================================================
async function parse_skilltree() {
    data_file = `skilltree/skilltree.json`;
    try {
        const response = await fetch(data_file);
        if (!response.ok) {
            throw new Error(`[parse_waveset] Response status: ${response.status}`);
        }

        skilltree_data = await response.json();
    } catch (error) {
        console.error(`[parse_waveset] ${error.message}`);
    }

    console.log(`[parse_skilltree] Fetched ${data_file}`);
    window.requestAnimationFrame(draw);
}


parse_skilltree();