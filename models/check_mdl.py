import os
import struct

def check_mdl(filename):
    with open(filename, 'rb') as f:
        data = bytearray(f.read())
        
    version, = struct.unpack_from('i', data, 4)
    if version != 48:
        print(filename)
        print(f'\tSkipping unsupported version {version}') 
        return True
        
    bodypart_count, bodypart_offset = struct.unpack_from('ii', data, 232)
    for i in range(bodypart_count):
        bodypart = bodypart_offset + i * 16     
        model_count, model_base, model_offset = struct.unpack_from('iii', data, bodypart + 4)
        for j in range(model_count):
            model = bodypart + model_offset + j * 148           
            mesh_count, mesh_offset = struct.unpack_from('ii', data, model + 72)
            for k in range(mesh_count):
                mesh = model + mesh_offset + k * 116               
                vertex_data_offset = mesh + 48
                lods = struct.unpack_from('8i', data, vertex_data_offset + 4)
                if any(lod == 0 for lod in lods):
                    print(filename)
                    print(f'\tDetected corrupt vertex data: {lods}')
                    return False

    
    return True
    
def process_files(directory):
    file_count = 0
    error_count = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.mdl'):
                file_count += 1
                if not check_mdl(os.path.join(root, file)):
                    error_count += 1
    return file_count, error_count

file_count, error_count = process_files('.')
print(f'\nFound {error_count} errors in {file_count} files')
os.system("pause")