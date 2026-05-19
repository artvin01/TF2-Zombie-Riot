// subweapon renderer
// GLOBALS ===================================================
let swr_refresh = false;
let swr_canvas;
let ctx;

let last_mousepos = [0,0];
let campos = [0,0];
let reset_cam = true;

// TODO reliable subweapon id generation
let swr_item = {};
let swr_highlight = {"id": -1, "time":0};

// MOUSE FUNCTIONS ===================================================
var mousedown = false;
let mouseclick = [false,false,false];
let mousepos = [0,0];

function setPrimaryButtonState(event) {
  if (event.type==="mousedown") {
    mouseclick[event.button] = true;
  };
  if (ctx.canvas.style.cursor==="grab" | ctx.canvas.style.cursor==="grabbing") {
    var flags = event.buttons !== undefined ? event.buttons : event.which;
    mousedown = ((flags & 1) === 1);
  }
};

function swr_setup() {
  ctx = swr_canvas.getContext("2d");
  swr_canvas.addEventListener("mousedown", setPrimaryButtonState);
  swr_canvas.addEventListener("touchstart", setPrimaryButtonState);
  document.addEventListener('mousemove', function(event) {
      bounds = ctx.canvas.getBoundingClientRect();
      mousepos = [event.clientX-bounds.left, event.clientY-bounds.top];
      if ((event.clientX < bounds.left) || (event.clientY < bounds.top) || (event.clientX > bounds.right) || (event.clientY > bounds.bottom)) {
        mousedown = false;
      }
  });
  swr_canvas.oncontextmenu = function() {
    return false;
  }
  swr_canvas.addEventListener("mouseup", setPrimaryButtonState);
}


// DRAW ===================================================
function draw() {
  let bbox = ctx.canvas.getBoundingClientRect();
  ctx.canvas.width = bbox.width;
  ctx.canvas.height = bbox.height;

  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  if (reset_cam) {
    campos = [ctx.canvas.width/2,ctx.canvas.height/2];
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

  ctx.fillStyle=`rgba(255,0,0,50%)`;
  
  ctx.canvas.style.cursor = "grab";
  parse_main(swr_item, campos[0]-(subweapon_dist+38), campos[1]-38, 0, "a");
  particles_tick();
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
particles = []
const subweapon_dist = 76 + 50;
function parse_main(data,px,py,angle,sw_id) {
  // calculate tri_x and tri_y given length and angle
  const tri_y = subweapon_dist * Math.sin(angle);
  const tri_x = Math.sqrt(subweapon_dist**2 - tri_y**2);

  const xoff = (px-campos[0])+tri_x;
  const yoff = (py-campos[1])+tri_y;
  const x = xoff+campos[0];
  const y = yoff+campos[1];

  if (run.length>0) {
    // Draw line from parent to own
    prerun.push({
      "type": "line",
      "lineWidth": 5,
      "strokeStyle": "#cbc7c0",
      "from": [px+32+6, py+32+6],
      "to": [x+32+6,y+32+6]
    });
  };

  // Draw rect
  run.push({
    "type": "button",
    "fillStyle": "#282828",
    "strokeStyle": "#ccc8c1",
    "pos": [x,y],
    "size": [76,76],
    "onhover": {
      "fillStyle": "#333333",
      "func": function(data) {
        let totalHeight = 70;
        let maxWidth = 0;
        let element_queue = [];
        let tooltip_yoff = 0; // Tooltip Y Offset
        // Draw weapon name
        element_queue.push({
          "type": "text",
          "fillStyle": "#ccc8c1",
          "textAlign": "center",
          "text": data.name,
          "pos": [mousepos[0], mousepos[1]+totalHeight+tooltip_yoff],
          "font": "1.5em Oswald"
        });
        let size = calc_text_size("1.5em Oswald", data.name);
        totalHeight += size.height + 5;
        maxWidth = Math.max(maxWidth, size.width)
        
        // Draw weapon tags, author
        secondary_text = [];
        if (data.tags!=={}) { secondary_text.push(data.tags.join(" ")) };
        if (data.author!==undefined) { secondary_text.push(data.author) };
        secondary_text.forEach(line => {
          element_queue.push({
            "type": "text",
            "fillStyle": "#95948f", //secondary color
            "textAlign": "center",
            "text": line,
            "pos": [mousepos[0], mousepos[1]+totalHeight+tooltip_yoff],
            "font": "italic 16px Noto Sans"
          });
          size = calc_text_size("italic 16px Noto Sans", line);
          totalHeight += size.height + 10;
          maxWidth = Math.max(maxWidth, size.width)
        });

        // Draw weapon desc
        data.description.split("\n").forEach(line => {
          line=remove_morecolors(line);
          element_queue.push({
            "type": "text",
            "fillStyle": "#ccc8c1",
            "textAlign": "center",
            "text": line,
            "pos": [mousepos[0], mousepos[1]+totalHeight+tooltip_yoff],
            "font": "16px Noto Sans"
          });
          size = calc_text_size("16px Noto Sans", line);
          totalHeight += size.height + 5;
          maxWidth = Math.max(maxWidth, size.width)
        });

        // Draw weapon attributes
        // holy nesting hell
        let attr_box_height = 0;
        let attr_box_y;
        if (Object.keys(data["attributes"]).length>0) {
          totalHeight += 10;
          attr_box_y = totalHeight-16;
          totalHeight += 5;
          ATTRIBUTE_TYPES.forEach(attr_type => {
              if (attr_type in data["attributes"]) {
                  data["attributes"][attr_type].forEach(attribute => {
                      attribute.split("\n").forEach(line => {
                        element_queue.push({
                          "type": "text",
                          "fillStyle": attr_type==="positive" ? "#99CCFF" : (attr_type==="negative" ? "#FF4040" : "#ccc8c1"),
                          "textAlign": "center",
                          "text": line,
                          "pos": [mousepos[0], mousepos[1]+totalHeight+tooltip_yoff],
                          "font": "16px Noto Sans"
                        });
                        size = calc_text_size("16px Noto Sans", line);
                        totalHeight += size.height + 5;
                        attr_box_height += size.height + 5;
                        maxWidth = Math.max(maxWidth, size.width)
                      });
                  });
              };
          });
        };
        // push bg first, then content
        postrun.push({
          "type": "rect",
          "fillStyle": "#181a1b",
          "strokeStyle": "#ccc8c1",
          "lineWidth": 1,
          "size": [maxWidth+50,16+50+(totalHeight-70)],
          "pos": [mousepos[0]-(maxWidth/2)-25, mousepos[1]+15+tooltip_yoff]
        });
        if (Object.keys(data["attributes"]).length>0) {
          postrun.push({
            "type": "rect",
            "fillStyle": "#26292b",
            "size": [maxWidth+50-32,attr_box_height+10],
            "pos": [mousepos[0]-(maxWidth/2)-25+16, mousepos[1]+attr_box_y+tooltip_yoff]
          });
        };
        postrun = postrun.concat(element_queue);
      },
      "args": [data]
    },
    "onrclick": {
      "args": [data],
      "func": function(data) {
        // copy link
        let source_url = window.location.href.split('?')[0]; // get url w/o params
        navigator.clipboard.writeText(`${source_url}?wid=${swr_item.wid}&swid=${sw_id}`);
        particles.push({
          "pos": [mousepos[0], mousepos[1]-32],
          "start": Date.now() 
        })
      }
    }
  })
  
  // Weapon Icon
  postrun.push({
    "type": "image",
    "pos": [x+7, y+7],
    "size": [64,64],
    "path": data.icon.length>0 ? data.icon : "builtin_img/missing_item_gray.svg"
  })

  // Weapon Cost
  let size = calc_text_size("16px Noto Sans", data.cost);
  const top = (y+74)-size.height-5;
  postrun.push({ // bg
    "type": "roundrect",
    "fillStyle": "rgba(83, 123, 22, 50%)",
    "pos": [x,top],
    "size": [size.width,size.height+6]
  });
  postrun.push({ // text
    "type": "text",
    "fillStyle": "#ffffff",
    "textAlign": "left",
    "text": data.cost,
    "pos": [x,top+size.height+2.5],
    "font": "16px Noto Sans"
  });

  // Highlight overlay
  if (swr_highlight.id===sw_id) {
    let alpha = Math.abs(Math.sin(Date.now()/400))*30;
    if ( (swr_highlight.time>Date.now()) || (swr_highlight.time!==0 && alpha>1) ) { // second condition is to smoothly fade out instead of vanishing
      postrun.push({
        "type": "roundrect",
        "fillStyle": `rgba(255, 255, 255, ${alpha}%)`,
        "pos": [x,y],
        "size": [76, 76]
      });
    } else {
      swr_highlight.id = -1
      swr_highlight.time = 0
    }
  }
  
  if (data.subweapons!==undefined && data.subweapons.items !== undefined) {
    let part = 2*Math.PI / (data.subweapons.items.length+1);
    data.subweapons.items.forEach(function(val,idx){
      let new_angle = part*idx;
      let new_sw_id = sw_id + "abcd".slice(idx,idx+1);
      if (part !== Math.PI) {
        new_angle -= part * 0.5 * (data.subweapons.items.length-1);
      }
      parse_main(val,x,y, new_angle, new_sw_id);
    });
  };
}

// Draw "Link copied!" popups for subweapons. Hardcoded for now.
let last_time = Date.now();
function particles_tick() {
  let size = calc_text_size("16px Noto Sans", "Link copied!");
  let dt = Date.now() - last_time;
  particles.forEach((particle, idx) => {
    let lifetime = Date.now() - particle.start;
    if (lifetime <= 1000) {
      // move
      particle.pos[1] -= dt/50;
      // render
      let opacity = (1000-lifetime)/1000;
      postrun.push({ // bg
        "type": "roundrect",
        "fillStyle": `rgba(83, 123, 22, ${50*opacity}%)`,
        "pos": [particle.pos[0]-(size.width/2)-2, particle.pos[1]],
        "size": [size.width+4,size.height+6]
      });
      postrun.push({ // text
        "type": "text",
        "fillStyle": `rgba(255, 255, 255, ${100*opacity}%)`,
        "textAlign": "left",
        "text": "Link copied!",
        "pos": [particle.pos[0]-(size.width/2), particle.pos[1]+size.height+2.5],
        "font": "16px Noto Sans"
      });
    } else {
      particles.splice(idx,1);
    }
  });
  last_time = Date.now();
}

IMG_CACHE = {};
function render(arr) {
  arr.forEach(function(element) {
    // TODO switch case
    if (element.type === "text") {
      ctx.save()
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.textAlign=element.textAlign;
      ctx.font = element.font;
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
      ctx.fillStyle=element.fillStyle;
      events = UiRect(ctx,...element.pos,...element.size,element.onhover)
      if (events.includes("hover")) {
        ctx.fillStyle = element.onhover.fillStyle;
      }
      if (events.includes("rclick")) {
        element.onrclick.func(...element.onrclick.args);
      }
      ctx.fill();
      if (element.strokeStyle !== undefined) {
        ctx.lineWidth = 2;
        ctx.strokeStyle = element.strokeStyle;
        ctx.stroke();
      }
      ctx.restore();
    } else if (element.type === "rect") {
      ctx.save();
      ctx.beginPath();
      ctx.rect(...element.pos,...element.size);
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.fill();
      if (element.strokeStyle !== undefined) {
        ctx.lineWidth = element.lineWidth;
        ctx.strokeStyle = element.strokeStyle;
        ctx.stroke();
      }
      ctx.restore();
    } else if (element.type === "roundrect") {
      ctx.save();
      ctx.beginPath();
      ctx.roundRect(...element.pos,...element.size,5);
      ctx.fillStyle=element.fillStyle; // Text color
      ctx.fill();
      if (element.strokeStyle !== undefined) {
        ctx.lineWidth = element.lineWidth;
        ctx.strokeStyle = element.strokeStyle;
        ctx.stroke();
      }
      ctx.restore();
    } else if (element.type === "image") {
      if (IMG_CACHE[element.path]===undefined) {
        IMG_CACHE[element.path] = new Image();
        IMG_CACHE[element.path].src = element.path;
      };
      let cached = IMG_CACHE[element.path];
      if (cached.then === undefined) {
        ctx.drawImage(cached,element.pos[0],element.pos[1],element.size[0],element.size[1])
      };
    }
  })
  return [];
}

// UTIL ===================================================
function UiRect(ctx,x,y,w,h,onhover) {
  ctx.roundRect(x,y,w,h,5);
  if (mousepos[0]>=x && mousepos[0]<=x+w && mousepos[1]>=y && mousepos[1]<=y+h && ctx.canvas.matches(":hover")) {
    onhover.func(...onhover.args);
    events = ["hover"];
    if (mouseclick[2]) { events.push("rclick") };
    return events;
  }
  return [];
}
function longestString(array) {
    return array.reduce(function (a, b) {
        return a.length > b.length ? a : b;
    });
}
function calc_text_size(font, text) {
  ctx.save();
  ctx.font = font;
  res = ctx.measureText(text);
  res.height = res.actualBoundingBoxAscent + res.actualBoundingBoxDescent;
  ctx.restore();
  return res;
}