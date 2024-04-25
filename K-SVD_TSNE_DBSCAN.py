#%%训练字典
import os
from sklearn.decomposition import DictionaryLearning
from PIL import Image
from sklearn.cluster import DBSCAN
from sklearn.manifold import TSNE
import re
import matplotlib.pyplot as plt
import time
import numpy as np
from sklearn import metrics
import pandas as pd

path_train=r"C:\Users\25891\Desktop\代码测试\时频图"#训练图像的路径
path_test=r"C:\Users\25891\Desktop\代码测试\时频图"#测试图像的路径

#输出稀疏向量的文件夹路径
path_xishu=r"C:\Users\25891\Desktop\代码测试\特征稀疏向量\\"#将字典学习到的稀疏向量输出

#读取稀疏向量的文件夹的路径
path_xishu_wen=r"C:\Users\25891\Desktop\代码测试\特征稀疏向量"#用于聚类

#获取指定文件夹内的所有文件的绝对路径并排序
def get_all_paths(directory_path):
    all_path=[]
    # 使用 os.listdir 读取目录中的文件
    files = os.listdir(directory_path)
    # 使用正则表达式提取文件名中的数字，并转换为整数，用于排序
    def extract_number(filename):
        match = re.search(r'(\d+)', filename)
        if match:
            return int(match.group(1))
        return float('inf')  # 对于不匹配的文件名，返回一个很大的数，以便它们排在最后
    # 按照提取的数字进行排序
    sorted_files = sorted(files, key=extract_number)
    # 现在 sorted_files 是按照数字顺序排列的文件列表
    for file in sorted_files:
        # 构造完整的文件路径
        file_path = os.path.join(directory_path, file)
        all_path.append(file_path)
    return all_path


#加载图片
def load_image(image_path,target_size):
    image_data = []
    for i in image_path:
        image_data.append(np.array(Image.open(i).resize(target_size).convert('L')))
    return image_data

# 从图片中提取特征（例如，使用图像块）
def extract_features(image_array, patch_size):
    num_patches_height = image_array.shape[0] // patch_size[0]
    num_patches_width = image_array.shape[1]  // patch_size[1]
    # 初始化一个列表来存储图像块
    patches = []
    # 提取不重叠的图像块
    for i in range(num_patches_height):
        for j in range(num_patches_width):
            # 提取图像块
            patch = image_array[i * patch_size[0]: (i + 1) * patch_size[0],
                    j * patch_size[1]: (j + 1) * patch_size[1]]
            patches.append(patch)
            # patches 现在包含了所有的不重叠图像块
    # 可以将其重塑为适合进一步处理的形状，例如 (-1, patch_size[0] * patch_size[1])
    patches = np.array(patches).reshape(-1, patch_size[0] * patch_size[1])
    return patches


# 训练字典
def train_dictionary(training_images, patch_size, n_components):
    patches = []
    for image in training_images:
        patches.extend(extract_features(image, patch_size))
    dl = DictionaryLearning(n_components=n_components, alpha=1, max_iter=1000, tol=1e-3)
    code, dictionary = dl.fit_transform(patches), dl.components_
    return dictionary, code,dl  # 返回字典、编码和DictionaryLearning对象


# 使用字典对图片进行稀疏表示
def sparse_code_image(image, dictionary,dl):
    patches=extract_features(image,patch_size)
    code = dl.transform(patches)  # 使用transform方法计算稀疏编码
    return code

#======================主程序================================
patch_size = (32,32)  # 图像块大小
n_components = 60  # 字典中原子的数量


target_size= (256, 256)
image_path=get_all_paths(path_train)#加载路径
image_static=load_image(image_path,target_size)#加载图片
train_images=image_static[0:len(image_static):5]#训练数据

image_path=get_all_paths(path_test)#加载路径
test_image=load_image(image_path,target_size)#测试数据

#训练字典
start_time = time.time()
dictionary, train_code,dl = train_dictionary(train_images, patch_size, n_components)
end_time = time.time()
xunliantime=end_time - start_time
#对测试图片进行稀疏向量的保存
q=1
start_time = time.time()
for i in test_image:
   test_code = sparse_code_image(i, dictionary,dl).reshape(-1)
   np.savetxt(path_xishu+str(q)+'.txt', test_code,fmt='%.2f')
   q=q+1
end_time = time.time()
xishutime=end_time - start_time
#%%
#进行聚类
def load_data(path):
    data=[]
    for i in path:
        data.append(np.loadtxt(i))
    return data

path_xishu=get_all_paths(path_xishu_wen)
static=load_data(path_xishu)
#============================数据降维=====
start_time = time.time()
tsne = TSNE(n_components=2, random_state=0)
static=np.array(static)
static_2d = tsne.fit_transform(static)
#=======================================

#==============进行聚类====================
cluster_index=np.array(DBSCAN(eps=4,min_samples=2).fit_predict(static_2d))
end_time = time.time()

juleitime=end_time - start_time#计算程序运行的时间

#=====现在我们查看每一类测试数据的聚类标签，可视化聚类结果=======
a=np.unique(cluster_index)
X = static
y = cluster_index
for i ,label in zip(range(0,len(a)), range(0,len(a))):
    plt.scatter(static_2d[y == i, 0], static_2d[y == i, 1], label=label)
plt.legend()
plt.show()

print("训练字典时间: ",xunliantime , "秒")
print("稀疏表示: ",xishutime , "秒")
print("聚类时间: ",juleitime , "秒")


#===============计算ARI数值===========================
label=[]
for c in range(7):
    for i in range(150):
        label.append(c)
ARI=metrics.adjusted_rand_score(label, list(cluster_index))
print("ARI: ",ARI )
df = pd.DataFrame(static_2d, columns=['Column1', 'Column2'])
df.to_excel('坐标.xlsx', index=False, engine='openpyxl')
