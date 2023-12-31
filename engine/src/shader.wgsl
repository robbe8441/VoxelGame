struct CameraUniform {
    view_proj: mat4x4<f32>,
};
@group(0) @binding(0)
var<uniform> camera: CameraUniform;

struct InstanceInput {
    @location(5) model_matrix_0: vec4<f32>,
    @location(6) model_matrix_1: vec4<f32>,
    @location(7) model_matrix_2: vec4<f32>,
    @location(8) model_matrix_3: vec4<f32>,
};



struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) uv_cords: vec2<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) uv_cords: vec3<f32>,
};

@vertex
fn vs_main(
    model: VertexInput,
    instance: InstanceInput,
) -> VertexOutput {

  let model_matrix = mat4x4<f32>(
        instance.model_matrix_0,
        instance.model_matrix_1,
        instance.model_matrix_2,
        instance.model_matrix_3,
    );

    var out: VertexOutput;
    out.clip_position = camera.view_proj * model_matrix * vec4<f32>(model.position, 1.0);
    out.uv_cords = model.position;
    return out;
}



struct Uniforms {
  cam_x : f32,
  cam_y : f32,
  cam_z : f32,
}

@group(1) @binding(1)
var t_diffuse: texture_3d<u32>;
@group(1) @binding(2)
var<uniform> uniforms: Uniforms;

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
  let cam_pos = vec3(uniforms.cam_x, uniforms.cam_y, uniforms.cam_z);
  let start_pos = in.uv_cords + vec3(1.0);
  let dir = normalize(cam_pos - in.uv_cords);

  for (var i=0; i<2000; i=i+1) {
    let checkpos = start_pos + (dir / vec3(500.0)) * vec3(f32(-i));

    if checkpos.x > 2.0 || checkpos.x < 0.0 || checkpos.z > 2.0 || checkpos.z < 0.0 || checkpos.y < 0.0 || checkpos.y > 2.0 {
      return vec4(0.0);
    }

    let pos = checkpos * vec3(49.999);
    let val = textureLoad(t_diffuse, vec3i(i32(pos.x) % 100, i32(pos.y) % 100, i32(pos.z) % 100), 0);

    if any(val.r != 0u) {
        return vec4(f32(val.r) / f32(i));
    }
  }
  return vec4(0.0);
}
