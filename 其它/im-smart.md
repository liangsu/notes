

npx pbjs -t static-module -w commonjs -o proto/bundle.js proto/*.proto


npx pbjs -t static-module -w commonjs -o common/ImMsgProtocol.js common/ImMsgProtocol.proto




npx pbjs -t json-module -w commonjs -o common/proto.js  common/ImMsgProtocol.proto --es6 common/proto.js




npx pbjs -t json common/ImMsgProtocol.proto > common/proto.json 


function readByte(bb) {
  return bb.bytes[advance(bb, 1)];
}

function readBytes(bb, count) {
  let offset = advance(bb, count);
  return bb.bytes.subarray(offset, offset + count);
}

function advance(bb, count) {
  let offset = bb.offset;
  if (offset + count > bb.limit) {
    throw new Error('Read past limit');
  }
  bb.offset += count;
  return offset;
}

function wrapByteBuffer(bytes) {
  return { bytes, offset: 0, limit: bytes.length };
}



function writeByte(bb, value) {
  let offset = grow(bb, 1);
  bb.bytes[offset] = value;
}

let bbStack = [];

function popByteBuffer() {
  const bb = bbStack.pop();
  if (!bb) return { bytes: new Uint8Array(64), offset: 0, limit: 0 };
  bb.offset = bb.limit = 0;
  return bb;
}

   crypto.policy=unlimited
   
   
   
				<scroll-view :scroll-top="scrollTop" scroll-y="true" class="scroll-Y" @scrolltoupper="upper"
					@scrolltolower="lower" @scroll="scroll">


