const C=window.CFG,$=i=>document.getElementById(i),sb=supabase.createClient(C.SUPABASE_URL,C.SUPABASE_ANON_KEY);
const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const jget=k=>{try{return JSON.parse(localStorage[k]||"[]")}catch(e){return[]}};
const D={store_name:"CHISHTI FABRICS",whatsapp:"923001234567",phone:"",email:"chishtifebrics@gmail.com",address:"",announcement:"Free delivery on orders above Rs. 5,000 · Cash on Delivery available",hero_title:"Ready to wear",hero_sub:"New season collection",hero_image:"",instagram:"",facebook:"",free_ship_min:"5000",ship_fee:"250",currency:"Rs.",
page_about:"Chishti Fabrics - quality fabrics and ready to wear for the whole family.",page_policies:"Exchange within 7 days (unused, with tags). Delivery in 3-5 working days. Cash on Delivery available.",page_faq:"Q: How do I order? A: Add items to cart and place the order; we confirm on WhatsApp.\nQ: Can I exchange? A: Yes, within 7 days.",page_contact:"We reply on WhatsApp and email."};
let BN=[],S={...D},CATS=[],P=[],cart=jget("cart"),wish=jget("wish"),rec=jget("rec"),cur,sz="",q=1,L=[],F={};
const fmt=n=>S.currency+" "+Number(n).toLocaleString(),price=p=>p.sale_price||p.price,enc=encodeURIComponent;
const groups=()=>[...new Set(CATS.map(c=>c.group_name))];
const img=u=>`style="background-image:url('${esc(u||"")}')"`;
function toast(m){$("toast").textContent=m;$("toast").classList.add("on");setTimeout(()=>$("toast").classList.remove("on"),1800)}
async function boot(){
 const[a,b,c,d]=await Promise.all([sb.from("settings").select("*"),sb.from("categories").select("*").order("sort").order("name"),sb.from("products").select("*").order("created_at",{ascending:false}),sb.from("banners").select("*").order("sort")]);
 if(c.error){$("view").innerHTML='<div class="empty">config.js mein Supabase keys check karein.</div>';return}
 (a.data||[]).forEach(r=>{if(r.value!==null&&r.value!=="")S[r.key]=r.value});CATS=b.data||[];P=c.data||[];BN=d.data||[];shell();route()}
function shell(){document.title=S.store_name;const R=document.documentElement.style;if(S.color_primary)R.setProperty("--g",S.color_primary);if(S.color_accent)R.setProperty("--gold",S.color_accent);$("logo").innerHTML=S.logo_image?`<img src="${esc(S.logo_image)}" alt="" style="height:40px;vertical-align:middle">`:esc(S.store_name);$("ann").textContent=S.announcement;$("ann").style.display=S.announcement?"":"none";
 const w="https://wa.me/"+S.whatsapp;$("wa").href=w;$("fab").href=w;$("tel").href="tel:"+(S.phone||"+"+S.whatsapp);
 $("nav").innerHTML=`<a href="#/new">New In</a>`+groups().map(g=>`<a href="#/g/${enc(g)}">${esc(g)}</a>`).join("")+`<a class="sale" href="#/sale">Sale</a>`;
 $("menu").innerHTML=`<button class="x" onclick="closeAll()">×</button><h3>MENU</h3><div class="lk"><a href="#/">Home</a><a href="#/new">New In</a>`+groups().map(g=>`<details open><summary>${esc(g)}</summary><div class="lk sub"><a href="#/g/${enc(g)}">All ${esc(g)}</a>${CATS.filter(c=>c.group_name==g).map(c=>`<a href="#/c/${enc(c.name)}">${esc(c.name)}</a>`).join("")}</div></details>`).join("")+`<a class="sale" href="#/sale" style="color:var(--red)">Sale</a><a href="#/wish">Wishlist</a><a href="#/page/about">About us</a><a href="#/page/contact">Contact us</a><a href="${w}" target="_blank">Chat on WhatsApp</a></div>`;
 const so=(u,n)=>u?`<a href="${esc(u)}" target="_blank">${n}</a>`:"";
 $("foot").innerHTML=`<div class="fg"><div><h4>${esc(S.store_name)}</h4><p>${esc(S.page_about).slice(0,140)}</p></div><div><h4>CUSTOMER CARE</h4><a href="${w}?text=Order%20tracking" target="_blank">Order Tracking</a><a href="#/page/policies">Policies</a><a href="#/page/faq">FAQ's</a><a href="#/page/contact">Contact Us</a></div><div><h4>INFORMATION</h4><a href="#/page/about">About Us</a><a href="#/page/store">Store Locator</a><a href="#/new">New Arrivals</a><a href="admin.html">Admin</a></div><div><h4>FOLLOW US</h4>${so(S.instagram,"Instagram")}${so(S.facebook,"Facebook")}<a href="mailto:${esc(S.email)}">${esc(S.email)}</a></div></div><p style="text-align:center;font-size:12px;margin-top:24px">© ${new Date().getFullYear()} ${esc(S.store_name)}</p>`;saveC()}
const openMenu=()=>{$("menu").classList.add("open");$("ov").classList.add("open")},closeAll=()=>{["menu","dr","ov"].forEach(i=>$(i).classList.remove("open"))},toggleSearch=()=>{$("sbar").classList.toggle("open");$("q").focus()};
function route(){const h=decodeURIComponent(location.hash.slice(1))||"/";const[,t,...r]=h.split("/"),a=r.join("/");scrollTo(0,0);closeAll();
 if(!t)home();else if(t=="c")list(P.filter(p=>p.category==a),a);else if(t=="g"){const cs=CATS.filter(c=>c.group_name==a).map(c=>c.name);list(P.filter(p=>cs.includes(p.category)),a,cs)}
 else if(t=="new")list(P.slice(0,30),"New In");else if(t=="sale")list(P.filter(p=>p.sale_price),"Sale");else if(t=="p")prod(a);
 else if(t=="s"){const k=a.toLowerCase();list(P.filter(p=>(p.name+" "+p.category+" "+(p.description||"")).toLowerCase().includes(k)),'Search: "'+a+'"')}
 else if(t=="wish")list(P.filter(p=>wish.includes(p.id)),"Wishlist");else if(t=="page")page(a)}
addEventListener("hashchange",route);
const card=p=>`<div class="card"><a href="#/p/${p.id}"><div class="im" ${img(p.images?.[0])}>${p.sale_price?`<span class="tag">${Math.round(100-p.sale_price/p.price*100)}% OFF</span>`:""}${p.in_stock?"":'<span class="tag so">Sold out</span>'}</div></a><button class="hrt" onclick="wl('${p.id}',this)">${wish.includes(p.id)?"♥":"♡"}</button><a href="#/p/${p.id}"><div class="nm">${esc(p.name)}</div></a><div class="pr">${p.sale_price?`<s>${fmt(p.price)}</s>${fmt(p.sale_price)}`:fmt(p.price)}</div></div>`;
function wl(id,b){wish=wish.includes(id)?wish.filter(x=>x!=id):[...wish,id];localStorage.wish=JSON.stringify(wish);if(b)b.textContent=wish.includes(id)?"♥":"♡";toast(wish.includes(id)?"Wishlist mein add":"Wishlist se hata diya")}
function home(){setTimeout(()=>go(0),0);const g=groups(),acc=CATS.filter(c=>c.group_name=="Accessories");
 $("view").innerHTML=`${hero()}
 <div class="trust"><div>🚚 Free delivery above ${fmt(S.free_ship_min)}</div><div>💵 Cash on Delivery</div><div>🔁 7 day exchange</div><div>💬 WhatsApp support</div></div>
 <h2 class="sec">Shop by Category</h2><div class="cats">${CATS.map(c=>`<a class="cat" href="#/c/${enc(c.name)}"><div ${img(c.image)}></div>${esc(c.name)}</a>`).join("")}</div>
 <div class="wrap"><h2 class="sec">Shop by Collection</h2><div class="tiles">${g.map(n=>{const c=CATS.find(x=>x.group_name==n);return`<a class="tile" href="#/g/${enc(n)}" ${img(c?.image)}><span>${esc(n)}</span></a>`}).join("")}</div>
 <h2 class="sec">New Arrivals</h2><div class="grid">${P.slice(0,8).map(card).join("")||'<div class="empty">Admin panel se products add karein.</div>'}</div><p style="text-align:center"><a class="btn" href="#/new">View all</a></p>
 ${P.some(p=>p.sale_price)?`<h2 class="sec" style="color:var(--red)">Sale</h2><div class="grid">${P.filter(p=>p.sale_price).slice(0,8).map(card).join("")}</div><p style="text-align:center"><a class="btn" href="#/sale">View sale</a></p>`:""}
 ${acc.length?`<h2 class="sec">Accessories</h2><div class="cats">${acc.map(c=>`<a class="cat" href="#/c/${enc(c.name)}"><div ${img(c.image)}></div>${esc(c.name)}</a>`).join("")}</div>`:""}
 ${rec.length?`<h2 class="sec">Recently Viewed</h2><div class="hs">${rec.map(i=>P.find(p=>p.id==i)).filter(Boolean).map(card).join("")}</div>`:""}</div>`}
function hero(){const b=BN.length?BN:[{image:S.hero_image,title:S.hero_title,subtitle:S.hero_sub,link:"#/new"}];
 return `<div class="hs2" id="hs">${b.map((x,i)=>`<div class="sl ${i?"":"on"}" ${img(x.image)}><div><h1>${esc(x.title)}</h1><p>${esc(x.subtitle)}</p><a class="btn" href="${esc(x.link||"#/new")}">Shop Now</a></div></div>`).join("")}${b.length>1?`<button class="ar l" onclick="go(si-1)">‹</button><button class="ar r" onclick="go(si+1)">›</button><div class="dots">${b.map((_,i)=>`<i class="${i?"":"on"}" onclick="go(${i})"></i>`).join("")}</div>`:""}</div>`}
let si=0;function go(i){const s=document.querySelectorAll("#hs .sl");if(!s.length)return;si=(i+s.length)%s.length;s.forEach((e,j)=>e.classList.toggle("on",j==si));document.querySelectorAll("#hs .dots i").forEach((e,j)=>e.classList.toggle("on",j==si))}
setInterval(()=>{if($("hs"))go(si+1)},5000);
function list(items,title,subs){L=items;F={sort:"new",size:"",stock:false};const sizes=[...new Set(items.flatMap(p=>p.sizes||[]))];
 $("view").innerHTML=`<div class="wrap"><div class="crumb"><a href="#/">Home</a> / ${esc(title)}</div><h1 class="ttl">${esc(title)}</h1>${subs?`<div class="chips">${subs.map(s=>`<a href="#/c/${enc(s)}">${esc(s)}</a>`).join("")}</div>`:""}
 <div class="tools"><span id="cnt"></span><select onchange="F.sort=this.value;paint()"><option value="new">Newest</option><option value="lo">Price: Low to High</option><option value="hi">Price: High to Low</option></select>${sizes.length?`<select onchange="F.size=this.value;paint()"><option value="">All sizes</option>${sizes.map(s=>`<option>${esc(s)}</option>`).join("")}</select>`:""}<label><input type="checkbox" onchange="F.stock=this.checked;paint()"> In stock</label></div><div class="grid" id="g"></div></div>`;paint()}
function paint(){let l=L.filter(p=>(!F.size||p.sizes?.includes(F.size))&&(!F.stock||p.in_stock));if(F.sort=="lo")l=[...l].sort((a,b)=>price(a)-price(b));if(F.sort=="hi")l=[...l].sort((a,b)=>price(b)-price(a));
 $("cnt").textContent=l.length+" PRODUCTS";$("g").innerHTML=l.map(card).join("")||'<div class="empty">Koi product nahi mila.</div>'}
function prod(id){cur=P.find(p=>p.id==id);if(!cur){$("view").innerHTML='<div class="empty">Product nahi mila.</div>';return}sz="";q=1;rec=[id,...rec.filter(x=>x!=id)].slice(0,8);localStorage.rec=JSON.stringify(rec);const im=cur.images||[];
 const rel=P.filter(p=>p.category==cur.category&&p.id!=id).slice(0,4);
 $("view").innerHTML=`<div class="wrap"><div class="crumb"><a href="#/">Home</a> / <a href="#/c/${enc(cur.category)}">${esc(cur.category)}</a> / ${esc(cur.name)}</div><div class="pd"><div><div class="main" id="mi" ${img(im[0])}></div><div class="thumbs">${im.map((u,i)=>`<div class="${i?"":"on"}" ${img(u)} onclick="pic(this,'${i}')"></div>`).join("")}</div></div>
 <div><h1 style="font:400 28px Georgia,serif;margin:0 0 10px">${esc(cur.name)}</h1><p style="font-size:22px;margin:0 0 14px"><b>${cur.sale_price?`<s style="color:var(--mut)">${fmt(cur.price)}</s> ${fmt(cur.sale_price)}`:fmt(cur.price)}</b></p>
 ${cur.sizes?.length?`<div>SIZE</div><div class="sizes">${cur.sizes.map(s=>`<button onclick="pick(this,'${esc(s)}')">${esc(s)}</button>`).join("")}</div>`:""}
 <div>QUANTITY</div><div class="qty"><button onclick="qq(-1)">−</button><span id="qv">1</span><button onclick="qq(1)">+</button></div>
 <button class="btn fill" ${cur.in_stock?"":"disabled"} onclick="add()">${cur.in_stock?"ADD TO CART":"SOLD OUT"}</button><br><br>
 <a class="btn gold" style="width:100%;text-align:center" target="_blank" href="https://wa.me/${S.whatsapp}?text=${enc("I want to order: "+cur.name+" - "+location.href)}">ORDER ON WHATSAPP</a><br><br><button class="btn sm" onclick="wl('${id}',this)">${wish.includes(id)?"♥ In wishlist":"♡ Add to wishlist"}</button>
 <details open><summary>Description</summary><p style="white-space:pre-line;color:var(--mut)">${esc(cur.description)}</p></details><details><summary>Delivery &amp; Returns</summary><p style="color:var(--mut)">${esc(S.page_policies)}</p></details></div></div>
 ${rel.length?`<h2 class="sec">You may also like</h2><div class="grid">${rel.map(card).join("")}</div>`:""}</div>`}
const pic=(e,i)=>{$("mi").style.backgroundImage=`url('${cur.images[i]}')`;document.querySelectorAll(".thumbs div").forEach(d=>d.classList.remove("on"));e.classList.add("on")},pick=(e,s)=>{sz=s;document.querySelectorAll(".sizes button").forEach(b=>b.classList.remove("on"));e.classList.add("on")},qq=d=>{q=Math.max(1,q+d);$("qv").textContent=q};
function page(a){const T={about:"About Us",policies:"Policies",faq:"FAQ's",contact:"Contact Us",store:"Store Locator"};let b=a=="store"?(S.address||"Address admin panel (Settings) se add karein."):S["page_"+a]||"";
 if(a=="contact")b+=`\n\nEmail: ${S.email}\nWhatsApp: +${S.whatsapp}${S.phone?"\nPhone: "+S.phone:""}${S.address?"\n"+S.address:""}`;
 $("view").innerHTML=`<div class="wrap"><h1 class="ttl">${T[a]||a}</h1><p style="white-space:pre-line;max-width:760px;line-height:1.7">${esc(b)}</p></div>`}
function add(){if(cur.sizes?.length&&!sz)return toast("Pehle size select karein");const k=cur.id+sz,f=cart.find(i=>i.k==k);f?f.q+=q:cart.push({k,id:cur.id,name:cur.name,size:sz,price:price(cur),img:cur.images?.[0],q});saveC();toast("Cart mein add ho gaya");openCart()}
function saveC(){localStorage.cart=JSON.stringify(cart);$("cn").textContent=cart.reduce((a,i)=>a+i.q,0)}
function openCart(){drawCart();$("dr").classList.add("open");$("ov").classList.add("open")}
const sub=()=>cart.reduce((a,i)=>a+i.price*i.q,0),ship=()=>sub()>=+S.free_ship_min?0:+S.ship_fee;
function drawCart(){$("ci").innerHTML=cart.length?cart.map((i,n)=>`<div class="row"><div class="t" ${img(i.img)}></div><div style="flex:1">${esc(i.name)}<br>${i.size?"Size "+esc(i.size)+" · ":""}${fmt(i.price)}</div><button onclick="qty(${n},-1)">−</button>${i.q}<button onclick="qty(${n},1)">+</button></div>`).join(""):"<p>Cart khali hai.</p>";
 $("cf").innerHTML=cart.length?`<p>Subtotal: ${fmt(sub())}<br>Delivery: ${ship()?fmt(ship()):"Free"}</p><h3>Total: ${fmt(sub()+ship())}</h3><input id="cn1" placeholder="Full name"><input id="cp" placeholder="Phone"><input id="cc" placeholder="City"><textarea id="ca" placeholder="Full address"></textarea><button class="btn fill" onclick="order()">PLACE ORDER (Cash on Delivery)</button>`:""}
function qty(n,d){cart[n].q+=d;if(cart[n].q<1)cart.splice(n,1);saveC();drawCart()}
async function order(){const c={name:$("cn1").value,phone:$("cp").value,city:$("cc").value,address:$("ca").value};if(!c.name||!c.phone||!c.address)return alert("Naam, phone aur address zaroori hain");const t=sub()+ship();
 await sb.from("orders").insert({customer:c,items:cart,total:t});
 const m=`New Order - ${S.store_name}\n`+cart.map(i=>`${i.q}x ${i.name} ${i.size||""} = ${i.price*i.q}`).join("\n")+`\nDelivery: ${ship()}\nTotal: ${t}\n${c.name}, ${c.phone}\n${c.city||""} ${c.address}`;
 cart=[];saveC();closeAll();window.open(`https://wa.me/${S.whatsapp}?text=${enc(m)}`,"_blank");toast("Order mil gaya, shukriya!")}
saveC();boot();
