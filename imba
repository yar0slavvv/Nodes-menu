import os

def main():
    print("Ноди на вибір:")
    print("1. Subspace")
    print("2. Якась шляпа")
    print("3. Шляпа 2")
    print("4. Я заєбався писать")
    print("5. Поможіть")

    choice = input("Введіть свій вибір: ")

    if choice == "1":
        os.system("bash <(curl -s https://raw.githubusercontent.com/cpiteam/Subspace/main/nodes)y")
    elif choice == "2":
        os.system("python node_b.py")
    elif choice == "3":
        os.system("python node_c.py")
    elif choice == "4":
        os.system("python node_d.py")
    elif choice == "5":
        os.system("python node_e.py")
    else:
        print("Неправильний вибір.")

if __name__ == "__main__":
    main()
